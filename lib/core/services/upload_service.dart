import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:passion_tree_frontend/core/config/api_config.dart';
import 'package:passion_tree_frontend/features/reflection_tree/domain/utils/error_utils.dart';
import 'package:passion_tree_frontend/features/authentication/data/datasources/auth_local_data_source.dart';

class UploadApiService {
  final AuthLocalDataSource _authLocalDataSource;

  UploadApiService({required AuthLocalDataSource authLocalDataSource})
      : _authLocalDataSource = authLocalDataSource;

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB in bytes

  /// Validate file size
  void _validateFileSize(Uint8List bytes) {
    if (bytes.length > maxFileSizeBytes) {
      final fileSizeMB = (bytes.length / (1024 * 1024)).toStringAsFixed(2);
      final maxSizeMB = (maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0);
      throw Exception(
        'File too large: ${fileSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB',
      );
    }
  }

  /// Validate file type by checking magic bytes (file signature)
  String _validateImageByMagicBytes(Uint8List bytes, String filename) {
    if (bytes.length < 12) {
      throw Exception('Invalid file: File too small to validate');
    }

    // Check JPEG (FF D8 FF)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // Check PNG (89 50 4E 47 0D 0A 1A 0A)
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }

    // Check if it's GIF (not supported)
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      throw Exception(
        'Only .jpg, .jpeg, and .png files are allowed.'
      );
    }

    // Check if it's WebP (not supported)
    if (bytes.length >= 16 &&
        bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        bytes[8] == 0x57 && // W
        bytes[9] == 0x45 && // E
        bytes[10] == 0x42 && // B
        bytes[11] == 0x50) { // P
      throw Exception(
        'Only .jpg, .jpeg, and .png files are allowed.'
      );
    }

    // If no match, throw exception
    throw Exception(
      'Only .jpg, .jpeg, and .png files are allowed.'
    );
  }

  Future<String?> validateImageFile(Uint8List bytes, String filename) async {
    try {
      _validateFileSize(bytes);
      _validateImageByMagicBytes(bytes, filename);
      return null; 
    } catch (e) {
      return ErrorUtils.extractErrorMessage(e);
    }
  }
  
  Future<Map<String, String>> getPresignedUrl(String filename, String folder) async {
    final url = Uri.parse('${ApiConfig.apiBackendUrl}/upload/presignedimg-url');
    
    // Get authentication token
    final token = await _authLocalDataSource.getToken();
    if (token == null) {
      throw Exception('Authentication required: No token found');
    }
    
    final response = await http.post(
      url,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({
        'filename': filename,
        'folder': folder,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final data = responseBody?['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          throw Exception('Invalid response: Missing data field');
        }
        
        final uploadUrl = data['upload_url'] as String?;
        final publicUrl = data['public_url'] as String?;
        
        if (uploadUrl == null || publicUrl == null) {
          throw Exception('Invalid response: Missing required URL fields');
        }
        
        return {
          'upload_url': uploadUrl, // URL สำหรับยิงไฟล์ขึ้น
          'public_url': publicUrl, // URL สำหรับเอาไปเก็บใน DB
        };
      } catch (e) {
        if (e.toString().contains('Invalid response')) {
          rethrow;
        }
        throw Exception('Failed to parse response: ${e.toString()}');
      }
    } else {
      // Parse error response body for detailed error message
      String errorMessage = 'Failed to get presigned URL';
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? errorBody['error'];
        if (message != null) {
          errorMessage = message;
        } else {
          errorMessage = '$errorMessage: ${response.statusCode}';
        }
      } catch (e) {
        // If parsing fails, use status code
        errorMessage = '$errorMessage: ${response.statusCode}';
      }
      
      if (response.statusCode == 401) {
        throw Exception('Unauthorized: $errorMessage');
      } else {
        throw Exception(errorMessage);
      }
    }
  }

  /// Get storage-specific headers for upload
  Map<String, String> _getStorageHeaders(String contentType) {
    return {
      'Content-Type': contentType,
      'x-ms-blob-type': 'BlockBlob',
    };
  }

  // 2. อัปโหลดไฟล์รูปไปยัง Blob Storage (PUT request)
  Future<void> uploadFileToBlob(
    String uploadUrl,
    Uint8List bytes,
    String filename,
  ) async {
    _validateFileSize(bytes);
    
    final contentType = _validateImageByMagicBytes(bytes, filename);
    
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: _getStorageHeaders(contentType),
      body: bytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Upload successful: ${response.statusCode}');
      return;
    }

    debugPrint('Upload failed with status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    String errorMessage = 'Failed to upload image to storage';
    try {
      // Try to parse error response (JSON or XML from cloud provider)
      final body = response.body;
      if (body.isNotEmpty) {
        errorMessage = '$errorMessage: $body (Status: ${response.statusCode})';
      } else {
        errorMessage = '$errorMessage: HTTP ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = '$errorMessage: HTTP ${response.statusCode}';
    }
    
    throw Exception(errorMessage);
  }
}