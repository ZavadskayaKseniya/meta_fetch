import 'package:meta_fetch/screens/edit_screen.dart';
import 'package:meta_fetch/screens/home_screen.dart';
import 'package:flutter/material.dart';

final Map<String, Widget Function(dynamic)> appRoutes = {
  //Screens
  'Home': (ctx) => HomeScreen(),
  'Edit': (ctx) => EditScreen(
        meta: null,
        onRemoveAllPressed: () {},
        onSavePressed: (dynamic) {},
      )
};
