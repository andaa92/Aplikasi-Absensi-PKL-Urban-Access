import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/landing-page.dart';
import 'package:absensi_pkl_urban/screen/login-page.dart';
import 'package:absensi_pkl_urban/screen/landing-page.dart';
import 'package:absensi_pkl_urban/screen/login-page.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Ensure that the file 'success-submit-page.dart' contains a class named 'SuccessSubmitPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  runApp(MyApp(isLoggedIn: token != null && token.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  

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
        
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      
    
      },

      
    );
  }
}

