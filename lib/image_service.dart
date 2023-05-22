import 'dart:convert';
import 'package:http/http.dart' as http;
import 'image_model.dart';

class ImageService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<ImageModel>> fetchImages() async {
    final response = await http.get(Uri.parse('$baseUrl/photos'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ImageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch images');
    }
  }
}
