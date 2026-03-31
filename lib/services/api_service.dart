import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/phrase_model.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get headers => {
        'Accept': 'application/json',
      };

  static Map<String, String> get jsonHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  static Uri _uri(String path) {
    return Uri.parse('${ApiConfig.baseUrl}$path');
  }

  static Map<String, dynamic> _safeDecodeToMap(String body) {
    if (body.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        'message': decoded.toString(),
      };
    } catch (_) {
      return {
        'message': body,
      };
    }
  }

  static List<dynamic> _safeDecodeToList(String body) {
    if (body.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(body);
      if (decoded is List<dynamic>) {
        return decoded;
      }

      if (decoded is Map && decoded['results'] is List) {
        return List<dynamic>.from(decoded['results'] as List);
      }

      if (decoded is Map && decoded['data'] is List) {
        return List<dynamic>.from(decoded['data'] as List);
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    final String message = data['message']?.toString().trim() ?? '';

    if (data['errors'] is Map) {
      final errors = Map<String, dynamic>.from(data['errors'] as Map);
      final allErrors = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          allErrors.addAll(value.map((e) => e.toString()));
        } else if (value != null) {
          allErrors.add(value.toString());
        }
      });

      if (allErrors.isNotEmpty) {
        return allErrors.join('\n');
      }
    }

    if (message.isNotEmpty) {
      return message;
    }

    if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
      return data['error'].toString().trim();
    }

    return 'تعذر تنفيذ الطلب، كود الحالة: $statusCode';
  }

  static Future<http.Response> _sendJsonRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    return await requestFn().timeout(_timeout);
  }

  static Future<http.Response> _sendMultipartRequest(
    http.MultipartRequest request,
  ) async {
    final streamedResponse = await request.send().timeout(_timeout);
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<void> _attachFileIfExists({
    required http.MultipartRequest request,
    required String fieldName,
    String? filePath,
  }) async {
    if (filePath == null || filePath.trim().isEmpty) return;

    final normalizedPath = filePath.trim();
    final file = File(normalizedPath);

    if (!await file.exists()) {
      throw Exception('الملف غير موجود في المسار المحدد: $normalizedPath');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        normalizedPath,
        filename: normalizedPath.split(Platform.pathSeparator).last,
      ),
    );
  }

  // =========================
  // Admin
  // =========================
  static Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    final uri = _uri('/admin/login');

    try {
      final response = await _sendJsonRequest(
        () => http.post(
          uri,
          headers: jsonHeaders,
          body: jsonEncode({
            'username': username.trim(),
            'password': password,
          }),
        ),
      );

      final data = _safeDecodeToMap(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تسجيل الدخول بنجاح',
          'admin': data['admin'],
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAdminProfile(int id) async {
    final uri = _uri('/admins/$id');

    try {
      final response = await _sendJsonRequest(
        () => http.get(uri, headers: headers),
      );

      final data = _safeDecodeToMap(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'admin': data['admin'],
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateAdminProfile({
    required int id,
    required String username,
    String? password,
    String? passwordConfirmation,
  }) async {
    final uri = _uri('/admins/$id/profile');

    try {
      final body = <String, dynamic>{
        'username': username.trim(),
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation ?? '';
      }

      final response = await _sendJsonRequest(
        () => http.put(
          uri,
          headers: jsonHeaders,
          body: jsonEncode(body),
        ),
      );

      final data = _safeDecodeToMap(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم التحديث بنجاح',
          'admin': data['admin'],
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  // =========================
  // Phrases
  // =========================
  static Future<List<PhraseModel>> getPhrases() async {
    final uri = _uri('/phrases');

    try {
      final response = await _sendJsonRequest(
        () => http.get(uri, headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _safeDecodeToList(response.body);
        return data.map((e) => PhraseModel.fromJson(e)).toList();
      }

      throw Exception('فشل تحميل العبارات');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } catch (e) {
      throw Exception('تعذر تحميل العبارات: $e');
    }
  }

  static Future<Map<String, dynamic>> addPhrase({
    required String text,
    required String type,
    required String gender,
    required String skinColor,
    String? imageFilePath,
  }) async {
    final uri = _uri('/phrases');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['text'] = text.trim();
      request.fields['type'] = type.trim();
      request.fields['gender'] = gender.trim();
      request.fields['skin_color'] = skinColor.trim();

      await _attachFileIfExists(
        request: request,
        fieldName: 'image',
        filePath: imageFilePath,
      );

      final response = await _sendMultipartRequest(request);
      final data = _safeDecodeToMap(response.body);

      print('ADD PHRASE STATUS: ${response.statusCode}');
      print('ADD PHRASE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'تمت إضافة العبارة بنجاح',
          'data': data['data'] ?? data,
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
        'data': data,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updatePhrase({
    required int id,
    required String text,
    required String type,
    required String gender,
    required String skinColor,
    String? imageFilePath,
  }) async {
    final uri = _uri('/phrases/$id');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['_method'] = 'PUT';
      request.fields['text'] = text.trim();
      request.fields['type'] = type.trim();
      request.fields['gender'] = gender.trim();
      request.fields['skin_color'] = skinColor.trim();

      await _attachFileIfExists(
        request: request,
        fieldName: 'image',
        filePath: imageFilePath,
      );

      final response = await _sendMultipartRequest(request);
      final data = _safeDecodeToMap(response.body);

      print('UPDATE PHRASE STATUS: ${response.statusCode}');
      print('UPDATE PHRASE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث العبارة بنجاح',
          'data': data['data'] ?? data,
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
        'data': data,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deletePhrase(int id) async {
    final uri = _uri('/phrases/$id');

    try {
      final response = await _sendJsonRequest(
        () => http.delete(uri, headers: headers),
      );

      final data = _safeDecodeToMap(response.body);

      print('DELETE PHRASE STATUS: ${response.statusCode}');
      print('DELETE PHRASE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف العبارة بنجاح',
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  // =========================
  // Lessons
  // =========================
  static Future<List<Map<String, dynamic>>> getLessons() async {
    final uri = _uri('/lessons');

    try {
      final response = await _sendJsonRequest(
        () => http.get(uri, headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _safeDecodeToList(response.body);
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      throw Exception('فشل تحميل الدروس');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } catch (e) {
      throw Exception('تعذر تحميل الدروس: $e');
    }
  }

  static Future<Map<String, dynamic>> addLesson({
    required String title,
    required String content,
    String? videoFilePath,
  }) async {
    final uri = _uri('/lessons');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['title'] = title.trim();
      request.fields['content'] = content.trim();

      await _attachFileIfExists(
        request: request,
        fieldName: 'video',
        filePath: videoFilePath,
      );

      final response = await _sendMultipartRequest(request);
      final data = _safeDecodeToMap(response.body);

      print('ADD LESSON STATUS: ${response.statusCode}');
      print('ADD LESSON BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'تمت إضافة الدرس بنجاح',
          'data': data['data'] ?? data,
          'upload': data['upload'],
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
        'data': data,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateLesson({
    required int id,
    required String title,
    required String content,
    String? videoFilePath,
  }) async {
    final uri = _uri('/lessons/$id');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['_method'] = 'PUT';
      request.fields['title'] = title.trim();
      request.fields['content'] = content.trim();

      await _attachFileIfExists(
        request: request,
        fieldName: 'video',
        filePath: videoFilePath,
      );

      final response = await _sendMultipartRequest(request);
      final data = _safeDecodeToMap(response.body);

      print('UPDATE LESSON STATUS: ${response.statusCode}');
      print('UPDATE LESSON BODY: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث الدرس بنجاح',
          'data': data['data'] ?? data,
          'upload': data['upload'],
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
        'data': data,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteLesson(int id) async {
    final uri = _uri('/lessons/$id');

    try {
      final response = await _sendJsonRequest(
        () => http.delete(uri, headers: headers),
      );

      final data = _safeDecodeToMap(response.body);

      print('DELETE LESSON STATUS: ${response.statusCode}');
      print('DELETE LESSON BODY: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف الدرس بنجاح',
        };
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, response.statusCode),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'انتهت مهلة الاتصال بالخادم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم: $e',
      };
    }
  }
}