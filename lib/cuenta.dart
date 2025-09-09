import 'package:flutter/material.dart';

class CuentaPage extends StatelessWidget {
  const CuentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuenta"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/inicio');
          },
        ),
      ),
      body: ListView(
        children: [
        
          _buildSectionTitle("Perfil"),
          _buildListTile(Icons.person, "Datos Personales",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.restaurant_menu, "Preferencias Alimenticias",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.location_on_outlined, "Direcciones",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.favorite_border, "Favoritos",
            iconColor: Colors.white, textColor: Colors.white),

          const Divider(),

    
          _buildSectionTitle("Actividad"),
          _buildListTile(Icons.account_balance_wallet_outlined, "Billetera"),

          const Divider(),

        
          _buildSectionTitle("Configuración"),
          _buildListTile(Icons.notifications_none, "Notificaciones",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.info_outline, "Información legal",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.store_mall_directory_outlined, "Registrar mi negocio",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.logout, "Cerrar sesión",
              iconColor: Colors.white, textColor: Colors.white),
          _buildListTile(Icons.delete_forever, "Eliminar cuenta",
              iconColor: Colors.white, textColor: Colors.white),
        ],
      ),
    );
  }



  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String text,
      {Color? iconColor, Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 👉 Aquí podrías navegar a otra pantalla si hace falta
      },
    );
  }
}
