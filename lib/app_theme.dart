import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fanbae/utils/color.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(TextTheme(
          headlineSmall: TextStyle(color: black),
          headlineMedium: TextStyle(color: black),
          bodyMedium: TextStyle(color: black),
          bodySmall: TextStyle(color: black),
        )),
      );

  static ThemeData darkTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(TextTheme(
          headlineSmall: TextStyle(color: white),
          headlineMedium: TextStyle(color: white),
          bodyMedium: TextStyle(color: white),
          bodySmall: TextStyle(color: white),
          bodyLarge: TextStyle(color: white),
          headlineLarge: TextStyle(color: white),
        )),
      );
}
