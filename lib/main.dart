import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/landing-page.dart';
import 'package:absensi_pkl_urban/screen/login-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/succes-submit-page.dart';

// Ensure that the file 'success-submit-page.dart' contains a class named 'SuccessSubmitPage'



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Absensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),

      // home: const MainPage(),
     
       
      initialRoute: '/landing', // <-- Mulai dari LandingPage
      routes: {
        '/izin': (context) => const FormIzin(),
        '/sakit': (context) => const FormSakit(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
        '/success': (context) => const SuccessSubmitPage(),
    
      },
    );
  }
}
