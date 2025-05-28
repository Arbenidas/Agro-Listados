import 'package:flutter/material.dart';

class ListDetailsScreen extends StatelessWidget {
  final String punto;
  final String fecha;

  const ListDetailsScreen({super.key, required this.punto, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Creando la lista")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Punto",
              ),
              controller: TextEditingController(text: punto),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Fecha",
                suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
              ),
              controller: TextEditingController(text: fecha),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Finalizar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
