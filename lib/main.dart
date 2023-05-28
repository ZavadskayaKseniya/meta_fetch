import 'package:flutter/material.dart';
import 'package:meta_fetch/navigation/routes.dart';
import 'package:meta_fetch/screens/home_screen.dart';
import 'package:pulp_flash/pulp_flash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PulpFlashProvider(
      child: MaterialApp(
        title: 'Random Images Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
        routes: appRoutes,
      ),
    );
  }
}
