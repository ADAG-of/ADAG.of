import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'datos_personales.dart';



class CuentaPage extends StatefulWidget {
  const CuentaPage({super.key});

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  String? dieta;
  List<String> alergias = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final response = await supabase
          .from('perfiles')
          .select('dieta, alergias')
          .eq('usuario_id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          dieta = response['dieta'] as String?;
          final alergiasData = response['alergias'];

          if (alergiasData is String) {
            alergias = alergiasData.isNotEmpty
                ? alergiasData.split(',').map((e) => e.trim()).toList()
                : [];
          } else if (alergiasData is List) {
            alergias = alergiasData.map((e) => e.toString()).toList();
          } else {
            alergias = [];
          }

          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Error al cargar preferencias: $e');
      setState(() => _loading = false);
    }
  }

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
          }
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionTitle("Perfil"),
                _buildListTile(
                  Icons.person,
                  "Datos Personales",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DatosPersonalesPage()),
                    );
                  },
                ),
                

                const Divider(),
                _buildSectionTitle("Configuración"),
                _buildListTile(
                  Icons.logout,
                  "Cerrar sesión",
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
                _buildListTile(
                  Icons.delete_forever,
                  "Eliminar cuenta",
                  onTap: () {
                    // 🚨 Aquí deberías agregar la lógica para eliminar la cuenta
                  },
                ),
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

  Widget _buildListTile(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
