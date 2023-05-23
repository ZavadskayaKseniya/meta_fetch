import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Colors
var primary = const Color.fromRGBO(123, 11, 163, 0.8);
var secondary = const Color.fromRGBO(0, 10, 255, 0.8);
var background = const Color.fromRGBO(249, 250, 251, 1);
var selection = const Color.fromRGBO(175, 175, 176, 1);
var textLight = Color.fromARGB(255, 247, 245, 245);
var textDark = Color.fromARGB(255, 0, 0, 0);
var textLightDark = Color.fromARGB(255, 135, 134, 134);

//textStyles

TextStyle titleStyle = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textDark,
);
TextStyle subTitleStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: textLightDark,
);
TextStyle bodyStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: textLight,
);

//gap

var medium = 16.0;
var small = 10.0;
var large = 20.0;
var extraLarge = 30.0;
var extraSmall = 6.0;
