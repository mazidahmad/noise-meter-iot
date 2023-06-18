import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'db Meter',
      debugShowCheckedModeBanner: false,
      home: const NoiseApp(),

      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
        primaryTextTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      themeMode: ThemeMode.light,
    );
  }
}
