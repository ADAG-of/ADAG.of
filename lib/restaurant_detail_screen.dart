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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(image, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 16),
          Center(
            child: Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(type, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Este restaurante ofrece una gran variedad de platos preparados con ingredientes frescos. Próximamente: menú detallado.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
