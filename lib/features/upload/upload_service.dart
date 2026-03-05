import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/core/network/log_handler.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

class UploadApiService {
  final http.Client client;

  UploadApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await getIt<AuthLocalDataSource>().getToken();
      if (token != null && token.isNotEmpty) {
        return ApiConfig.getAuthHeaders(token);
      }
    } catch (_) {}
    return ApiConfig.defaultHeaders;
  }

  Future<Map<String, String>> getPresignedUrl(
    String filename,
    String folder,
  ) async {
    try {
      LogHandler.debug('[DataSource] POST /upload/presignedimg-url');

      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await client.post(
        Uri.parse('${ApiConfig.apiBackendUrl}/upload/presignedimg-url'),
        headers: headers,
        body: jsonEncode({'filename': filename, 'folder': folder}),
      );

      LogHandler.debug('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final result = data['data'];

          if (result == null ||
              result['upload_url'] == null ||
              result['public_url'] == null) {
            throw Exception('Invalid URL data received from server');
          }

          return {
            'upload_url': result['upload_url'],
            'public_url': result['public_url'],
          };
        } on FormatException catch (e) {
          LogHandler.error('Failed to parse JSON response: $e');
          throw Exception(
            'Server returned invalid JSON response (possibly HTML error page)',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          LogHandler.error('Failed to get presigned URL: ${error['message']}');
          throw Exception(error['message'] ?? 'Failed to get presigned URL');
        } on FormatException {
          LogHandler.error(
            'Failed to get presigned URL (Status ${response.statusCode})',
          );
          throw Exception(
            'Failed to get presigned URL (Status ${response.statusCode})',
          );
        }
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in getPresignedUrl: $e');
      throw Exception('Failed to fetch presigned URL: $e');
    }
  }

  Future<void> uploadFileToBlob(String uploadUrl, File file) async {
    try {
      LogHandler.debug('[DataSource] PUT to Azure Blob Storage');

      final bytes = await file.readAsBytes();

      String contentType = 'image/jpeg';
      final extension = path.extension(file.path).toLowerCase();
      if (extension == '.png') {
        contentType = 'image/png';
      } else if (extension == '.pdf') {
        contentType = 'application/pdf';
      } else if (extension == '.doc' || extension == '.docx') {
        contentType = 'application/msword';
      }

      final response = await client.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType, 'x-ms-blob-type': 'BlockBlob'},
        body: bytes,
      );

      LogHandler.debug('Azure Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        LogHandler.error('Azure Error Body: ${response.body}');
        throw Exception(
          'Failed to upload file to storage (Status ${response.statusCode})',
        );
      }
    } on SocketException catch (e) {
      LogHandler.error('No internet connection during blob upload: $e');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      LogHandler.error('Connection timeout during blob upload: $e');
      throw Exception('Connection timeout. Please try again.');
    } on HttpException catch (e) {
      LogHandler.error('HTTP error during blob upload: $e');
      throw Exception('Network error. Please try again.');
    } catch (e) {
      LogHandler.error('Exception in uploadFileToBlob: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadImage(File file, String folder) async {
    try {
      LogHandler.debug('[DataSource] Starting uploadImage process');
      final filename = path.basename(file.path);
      final urls = await getPresignedUrl(filename, folder);

      await uploadFileToBlob(urls['upload_url']!, file);

      LogHandler.debug(
        '[DataSource] uploadImage process completed successfully',
      );
      return urls['public_url']!;
    } catch (e) {
      LogHandler.error('Exception in uploadImage helper: $e');
      rethrow;
    }
  }
}
