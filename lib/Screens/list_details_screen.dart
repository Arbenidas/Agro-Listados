import 'package:flutter/material.dart';

class ListDetailsScreen extends StatelessWidget {
  final String punto;
  final String fecha;

  ListDetailsScreen({required this.punto, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Creando la lista")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Punto",
              ),
              controller: TextEditingController(text: punto),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Fecha",
                suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
              ),
              controller: TextEditingController(text: fecha),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              icon: Icon(Icons.arrow_forward),
              label: Text("Finalizar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
