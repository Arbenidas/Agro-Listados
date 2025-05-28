import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';
import 'services/database_service.dart'; // Import the DatabaseService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo para desarrollo - reiniciar la base de datos
  try {
    await DatabaseService().resetDatabase();
    print('Base de datos reiniciada correctamente');
  } catch (e) {
    print('Error al reiniciar la base de datos: $e');
  }

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
      title: 'LogiTruck',
      theme: veggieMarketTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      key: UniqueKey(),
    );
  }
}
