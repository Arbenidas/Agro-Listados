import 'package:flutter/material.dart';
import 'list_details_screen.dart';

class CreateListScreen extends StatelessWidget {
  final TextEditingController _puntoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  CreateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proveedor - Creando la lista")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _puntoController,
              decoration: const InputDecoration(labelText: "Punto"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: "Fecha",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListDetailsScreen(
                            punto: _puntoController.text,
                            fecha: _fechaController.text,
                          )),
                );
              },
              child: const Text("Siguiente"),
            ),
          ],
        ),
      ),
    );
  }
}
