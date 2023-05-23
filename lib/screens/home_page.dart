import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:exif/exif.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> _imageUrls;
  bool _isLoading = true;
  String count = "5";
  final String pixabayToken = '36092338-469453db4863bfc0e58aba307';
  final String pixabayUrl =
      'https://pixabay.com/api/?key=36092338-469453db4863bfc0e58aba307&q=yellow+flowers&image_type=photo';

  Future<void> _fetchRandomImages() async {
    final String unsplashUrl =
        'https://api.unsplash.com/photos/random/?client_id=aKTPSoktcHRAFUSVVlN80GSC-2Ym2OaCBZL8p1Lon10&count=${count}';

    final response = await http.get(Uri.parse(unsplashUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List<dynamic>) {
        setState(() => {
              _imageUrls = data.map<String>((item) {
                if (item is Map<String, dynamic> && item.containsKey('urls')) {
                  return item['urls']['regular'];
                } else {
                  throw Exception('Invalid API response');
                }
              }).toList(),
              _isLoading = false
            });
      } else {
        throw Exception('Invalid API response');
      }
    } else {
      throw Exception('Failed to fetch images');
    }
  }

  void _onImagePressed(int index) async {
    if (index >= 0 && index < _imageUrls.length) {
      final imageUrl = _imageUrls[index];
      final response = await http
          .get(Uri.parse('$imageUrl?auto=format&fit=crop&w=0.5&q=80'));
      if (response.statusCode == 200) {
        print(response);
        final bytes = response.bodyBytes.toList();
        final data = await readExifFromBytes(bytes);
        print(data);

        if (data.isEmpty) {
          print("No EXIF information found");
          return;
        }

        if (data.containsKey('JPEGThumbnail')) {
          print('File has JPEG thumbnail');
          data.remove('JPEGThumbnail');
        }
        if (data.containsKey('TIFFThumbnail')) {
          print('File has TIFF thumbnail');
          data.remove('TIFFThumbnail');
        }

        for (final entry in data.entries) {
          print("${entry.key}: ${entry.value}");
        }
      } else {
        print('Failed to fetch image meta information');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRandomImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meta Fetch"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _imageUrls.length,
              itemBuilder: (BuildContext context, int index) {
                final imageUrl = _imageUrls[index];
                return GestureDetector(
                  onTap: () => _onImagePressed(index),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRandomImages,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
