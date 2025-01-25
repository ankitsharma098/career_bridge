import 'package:android/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(

      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        color: AppColors.primary, // AppBar background color
        elevation: 0, // Remove shadow
        //centerTitle: true, // Center the title
        titleTextStyle: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.white, // Title text color

        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Color of icons in AppBar
        ),
      ),

      textTheme: TextTheme(

        displayLarge: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: Colors.black,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.05,
          color: Colors.black,

        ),
        bodySmall: GoogleFonts.poppins(
          fontSize:  MediaQuery.of(context).size.width* 0.035, // 3.5% of screen width
          color: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }


  static ThemeData darkTheme(BuildContext context) {
    return  ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        color: Colors.blue[800], // Darker blue for dark theme
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      primaryTextTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Changed to white
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: Colors.white, // Changed from white70 to white
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          color: Colors.white, // Already white, but ensuring for clarity
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white, // Changed from white54 to white
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white.withOpacity(0.3),
        selectionHandleColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white54),
      ),

      cardTheme: CardTheme(
        color: Colors.grey[850],
        elevation: 4,
      ),

      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

}

