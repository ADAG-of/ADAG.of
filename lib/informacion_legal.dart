import 'package:flutter/material.dart';

class InformacionLegal extends StatelessWidget {
  const InformacionLegal({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Informacion Legal")),
      body: Center(child: Text("Aquí van tu Informacion Legal")),
    );
  }
}