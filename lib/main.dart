import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/form-izin.dart';
import 'package:absensi_pkl_urban/screen/form-sakit.dart';

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
      home: const MainPage(),
       routes: {
        '/izin': (context) => const FormIzin(),
        '/sakit': (context) => const FormSakit(),
      },
    );
  }
}
