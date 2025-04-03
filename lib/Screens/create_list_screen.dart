import 'package:flutter/material.dart';
import 'list_details_screen.dart';

class CreateListScreen extends StatelessWidget {
  final TextEditingController _puntoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proveedor - Creando la lista")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _puntoController,
              decoration: InputDecoration(labelText: "Punto"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: "Fecha",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 20),
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
              child: Text("Siguiente"),
            ),
          ],
        ),
      ),
    );
  }
}
