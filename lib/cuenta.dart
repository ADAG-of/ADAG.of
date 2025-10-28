import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'datos_personales.dart';
import 'preferencias_alimenticias.dart';
import 'direcciones.dart';
import 'favoritos.dart';
import 'notificaciones.dart';
import 'informacion_legal.dart';

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
            Navigator.pop(context); // ✅ Regresa a la pantalla anterior
          },
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
                      MaterialPageRoute(
                        builder: (context) => const DatosPersonales(),
                      ),
                    );
                  },
                ),
                
                _buildListTile(
                  Icons.restaurant_menu,
                  "Preferencias Alimenticias",
                  subtitle: dieta != null
                      ? "Dieta: $dieta\nAlergias: ${alergias.isEmpty ? "Ninguna" : alergias.join(", ")}"
                      : "No configuradas",
                  onTap: () {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      // Usar nombre si existe, si no el inicio del email, si no string vacío
                      final nombre = (user.userMetadata?['nombre'] as String?) ??
                          user.email?.split('@').first ??
                          '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreferenciasScreen(
                            email: user.email ?? '',
                            nombre: nombre,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Debes iniciar sesión para editar tus preferencias.")),
                      );
                    }
                  },
                ),

                _buildListTile(
                  Icons.location_on_outlined,
                  "Direcciones",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Direcciones(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  Icons.favorite_border,
                  "Favoritos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritosPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildSectionTitle("Configuración"),
                _buildListTile(
                  Icons.notifications_none,
                  "Notificaciones",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Notificaciones(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  Icons.info_outline,
                  "Información legal",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InformacionLegal(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  Icons.store_mall_directory_outlined,
                  "Registrar mi negocio",
                ),
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
