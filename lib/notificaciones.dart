import 'package:flutter/material.dart';

class Notificaciones extends StatelessWidget {
  const Notificaciones({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones")),
      body: Center(child: Text("Aquí van tus Notificaciones")),
    );
  }
}