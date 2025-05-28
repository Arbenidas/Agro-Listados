import 'package:flutter/material.dart';
import 'create_list_screen.dart';
import '../widgets/list_card.dart';

class ProviderScreen extends StatelessWidget {
  const ProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proveedor - Lista creada"),
        actions: const [
          Row(
            children: [
              Text("Sesión Iniciada"),
              SizedBox(width: 5),
              Icon(Icons.circle, color: Colors.green, size: 10),
            ],
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ListCard(title: "San Martín", details: "Lote productos: 1kg"),
          ListCard(title: "Aborí", details: "Lote productos: 2.00kg"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateListScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
