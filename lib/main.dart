import 'package:flutter/material.dart';
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
