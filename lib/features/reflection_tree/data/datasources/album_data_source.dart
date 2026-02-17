import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/reflection_tree/data/models/album_api_model.dart';

class AlbumDataSource {
  final http.Client client;

  AlbumDataSource({http.Client? client}) : client = client ?? http.Client();

  /// Create a new album
  Future<AlbumApiModel> createAlbum(CreateAlbumRequest request, String token) async {
    try {
      final url = Uri.parse(ApiConfig.albums);
      debugPrint('[AlbumDataSource] POST $url');
      debugPrint('Request body: ${jsonEncode(request.toJson())}');
      
      final response = await client.post(
        url,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('[AlbumDataSource] Response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('[AlbumDataSource] Album created successfully (Status: 201)');
        return AlbumApiModel.fromJson(data['data']['album']);
      } else {
        final error = jsonDecode(response.body);
        debugPrint('[AlbumDataSource] Error: ${error['message']}');
        throw Exception(error['message'] ?? 'Failed to create album');
      }
    } catch (e) {
      debugPrint('[AlbumDataSource] Exception: $e');
      throw Exception('Failed to create album: $e');
    }
  }

  /// Get album by ID
  Future<AlbumApiModel> getAlbumById(String albumId, String token) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConfig.albumById(albumId)),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AlbumApiModel.fromJson(data['data']['album']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get album');
      }
    } catch (e) {
      throw Exception('Failed to get album: $e');
    }
  }

  /// Get all albums by user ID
  Future<List<AlbumApiModel>> getAlbumsByUserId(String userId, String token) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConfig.albumsByUserId(userId)),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final albums = data['data']['albums'] as List;
        return albums.map((album) => AlbumApiModel.fromJson(album)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get albums');
      }
    } catch (e) {
      throw Exception('Failed to get albums: $e');
    }
  }

  /// Update album
  Future<void> updateAlbum(String albumId, UpdateAlbumRequest request, String token) async {
    try {
      final response = await client.put(
        Uri.parse(ApiConfig.albumById(albumId)),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update album');
      }
    } catch (e) {
      throw Exception('Failed to update album: $e');
    }
  }

  /// Delete album
  Future<void> deleteAlbum(String albumId, String token) async {
    try {
      final response = await client.delete(
        Uri.parse(ApiConfig.albumById(albumId)),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete album');
      }
    } catch (e) {
      throw Exception('Failed to delete album: $e');
    }
  }
}
