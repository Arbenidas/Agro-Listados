import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logitruck_app/screens/home_screen.dart';
import 'package:logitruck_app/screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';
import 'utils/page_transition.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro-listado',
      theme: veggieMarketTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return SlideRightRoute(page: const LoginScreen());
          case '/register':
            return SlideUpRoute(page: const RegisterScreen());
          case '/home':
          return FadeRoute(page: const HomeScreen());
          default:
            return null;
        }
      },
    );
  }
}
