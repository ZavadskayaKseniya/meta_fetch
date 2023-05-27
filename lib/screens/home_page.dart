import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:exif/exif.dart';
// import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';

import 'package:meta_fetch/utils/styles.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  var _meta;

  Future<void> _uploadImage(ImageSource source) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(source: source);
    } catch (e) {
      print(e);
    }

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage!.path);
      });

      setState(() async {
        _meta = await readExifFromFile(_imageFile!);
      });
    }
  }

  Future<void> _fetchRandomImages() async {

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
          flexibleSpace: Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 400,
                  child: _imageFile == null
                      ? Text('No image selected')
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location: Your Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'EXIF Data: ${_meta}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Select Image Source'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _uploadImage(ImageSource.gallery);
                  },
                  child: Text('Gallery'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _uploadImage(ImageSource.camera);
                  },
                  child: Text('Camera'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Upload Image',
        child: Icon(Icons.upload),
      ),
    );
  }
}
