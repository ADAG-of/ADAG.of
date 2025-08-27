import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String name;
  final String image;
  final String type;

  const RestaurantDetailScreen({
    required this.name,
    required this.image,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: Text(name)),
  body: SingleChildScrollView( // 👈 esto permite el desplazamiento
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(image, height: 150, fit: BoxFit.cover),
        const SizedBox(height: 16),
        Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            type,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Image.asset(
            'assets/images/NomadesMenu.png',  // tu imagen de menú
            fit: BoxFit.contain, // 👈 mejor que cover para que no se recorte
          ),
        ),
      ],
    ),
  ),
);

  }
}
