import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:aitchpredict/firebase_options.dart';
import 'login.dart'; 

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Jalankan aplikasi setelah inisialisasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const LoginPage(),  // Mulai dengan halaman LoginPage
    );
  }
}
