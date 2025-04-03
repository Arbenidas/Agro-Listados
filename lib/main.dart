import 'package:flutter/material.dart';
import 'Screens/login_screen.dart';

void main() {
  runApp(AgroListesApp());
}

class AgroListesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
      },
    );
  }
}
