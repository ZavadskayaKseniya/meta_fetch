import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:exif/exif.dart';
import 'package:meta_fetch/screens/home_page.dart' as home_page;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Images Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home_page.MyHomePage(),
    );
  }
}
