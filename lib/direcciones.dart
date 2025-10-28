import 'package:flutter/material.dart';

class Direcciones extends StatelessWidget {
  const Direcciones({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Direcciones")),
      body: Center(child: Text("Aquí van tus Direcciones")),
    );
  }
}