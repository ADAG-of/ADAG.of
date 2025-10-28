import 'package:flutter/material.dart';

class DatosPersonales extends StatelessWidget {
  const DatosPersonales({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Datos Personales")),
      body: Center(child: Text("Aquí van tus datos personales")),
    );
  }
}