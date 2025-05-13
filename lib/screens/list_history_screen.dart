import 'package:flutter/material.dart';

class ListHistoryScreen extends StatelessWidget {
  const ListHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Listas'),
      ),
      body: Center(
        child: Text('Pantalla de Historial de Listas'),
      ),
    );
  }
}
