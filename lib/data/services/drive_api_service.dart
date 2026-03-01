import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../../core/config/env.dart';
import '../../core/utils/logger.dart';

class DriveApiService {
  static String get _scriptUrl => Env.driveApiUrl;

  Future<http.Response> _postWithRedirects(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final parsedUrl = Uri.parse(_scriptUrl.trim());
    var response = await http
        .post(
          parsedUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        )
        .timeout(timeout);

    if (response.statusCode == 302 || response.statusCode == 303) {
      final location = response.headers['location'];
      if (location != null) {
        response = await http.get(Uri.parse(location)).timeout(timeout);
      }
    }
    return response;
  }

  Future<List<Book>> getFiles() async {
    try {
      final response = await _postWithRedirects({
        'action': 'list',
        'secret': Env.scriptSecretKey,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> filesJson = data['files'];
          return filesJson.map((json) => Book.fromJson(json)).toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to load files');
        }
      } else {
        throw Exception(
          'Failed to connect to Drive API (Status: ${response.statusCode})\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      logger.e('Error fetching files: $e');
      throw Exception('Error fetching files: $e');
    }
  }

  Future<Book> uploadFile(
    String base64File,
    String fileName,
    String mimeType,
  ) async {
    try {
      final response = await _postWithRedirects({
        'action': 'upload',
        'secret': Env.scriptSecretKey,
        'base64': base64File,
        'fileName': fileName,
        'mimeType': mimeType,
      }, timeout: const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Book(
            id: data['fileId'],
            title: data['name'],
            author: 'Unknown',
            url: '', // Can be gathered during next sync
            size: 0,
            dateCreated: DateTime.now(),
          );
        } else {
          throw Exception(data['error'] ?? 'Failed to upload file');
        }
      } else {
        throw Exception(
          'Failed to connect to Drive API (Status: ${response.statusCode})\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      logger.e('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> updateFile(
    String fileId,
    List<String> categories,
    String summary,
  ) async {
    try {
      final response = await _postWithRedirects({
        'action': 'update',
        'secret': Env.scriptSecretKey,
        'fileId': fileId,
        'categories': categories,
        'summary': summary,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['error'] ?? 'Failed to update file metadata');
        }
      } else {
        throw Exception(
          'Failed to connect to Drive API (Status: ${response.statusCode})\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      logger.e('Error updating file metadata: $e');
      throw Exception('Error updating file metadata: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final response = await _postWithRedirects({
        'action': 'delete',
        'secret': Env.scriptSecretKey,
        'fileId': fileId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['error'] ?? 'Failed to delete file');
        }
      } else {
        throw Exception(
          'Failed to connect to Drive API (Status: ${response.statusCode})\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      logger.e('Error deleting file: $e');
      throw Exception('Error deleting file: $e');
    }
  }
}
