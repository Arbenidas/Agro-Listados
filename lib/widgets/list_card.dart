import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String title;
  final String details;

  ListCard({required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          details,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Seleccionaste $title")),
          );
        },
      ),
    );
  }
}
