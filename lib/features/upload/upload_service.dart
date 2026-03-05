import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:passion_tree_frontend/core/config/api_config.dart';

class UploadApiService {
  
  // 1. ขอ Presigned URL จาก Backend
  Future<Map<String, String>> getPresignedUrl(String filename, String folder) async {
    final url = Uri.parse('${ApiConfig.apiBackendUrl}/upload/presignedimg-url');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'filename': filename,
        'folder': folder,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'upload_url': data['upload_url'], // URL สำหรับยิงไฟล์ขึ้น
        'public_url': data['public_url'], // URL สำหรับเอาไปเก็บใน DB
      };
    } else {
      throw Exception('Failed to get presigned URL');
    }
  }

  // 2. อัปโหลดไฟล์รูปไปยัง Blob Storage (PUT request)
  Future<void> uploadFileToBlob(String uploadUrl, File file) async {
    // อ่านไฟล์เป็น bytes
    final bytes = await file.readAsBytes();
    
    // ตรวจสอบนามสกุลไฟล์เพื่อใส่ Content-Type (สำคัญมากสำหรับ Blob Storage)
    String contentType = 'image/jpeg'; // ค่า Default
    final extension = path.extension(file.path).toLowerCase();
    if (extension == '.png') contentType = 'image/png';
    if (extension == '.pdf') contentType = 'application/pdf';
    else if (extension == '.doc' || extension == '.docx') contentType = 'application/msword';
    
    final response = await http.put( // ใช้ PUT ตามมาตรฐาน Presigned URL ส่วนใหญ่
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': contentType, 
        // บาง Storage อาจต้องการ headers เพิ่มเติมตามที่ Sign ไว้
        'x-ms-blob-type': 'BlockBlob',
      },
      body: bytes,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
       // ปริ้นท์ body ออกมาดูด้วยจะได้รู้ว่า Azure บ่นว่าอะไร
       debugPrint('Azure Error Body: ${response.body}'); 
       throw Exception('Failed to upload image to storage: ${response.statusCode}');
    }
  }

  // 3. Helper method รวม 2 steps เข้าด้วยกัน
  Future<String> uploadImage(File file, String folder) async {
    final filename = path.basename(file.path);
    
    // Step 1: Get presigned URL
    final urls = await getPresignedUrl(filename, folder);
    
    // Step 2: Upload file to blob storage
    await uploadFileToBlob(urls['upload_url']!, file);
    
    // Return public URL to store in database
    return urls['public_url']!;
  }
}
