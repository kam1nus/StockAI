import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';

class AIService {
  static String get baseUrl => AppConfig.backendBaseUrl;

  static Future<Map<String, dynamic>> analyzePhoto(
    XFile photo,
  ) async {
    AppConfig.requireBackendConfiguration();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/analyze'),
    );

    final bytes = await photo.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: photo.name,
      ),
    );

    final streamedResponse = await request.send();

    final response =
        await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Backend error ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }
}
