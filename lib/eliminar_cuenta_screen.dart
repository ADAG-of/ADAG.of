import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EliminarCuentaScreen extends StatefulWidget {
  const EliminarCuentaScreen({Key? key}) : super(key: key);

  @override
  State<EliminarCuentaScreen> createState() => _EliminarCuentaScreenState();
}

class _EliminarCuentaScreenState extends State<EliminarCuentaScreen> {
  bool _isDeleting = false;

  Future<void> _eliminarCuenta() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró un usuario activo.")),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text(
          "¿Estás seguro de que querés eliminar tu cuenta? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isDeleting = true);

    try {
      // 1️⃣ Eliminar perfil en tabla 'perfiles'
      await supabase.from('perfiles').delete().eq('usuario_id', user.id);

      // 2️⃣ Eliminar usuario de Auth (requiere RLS o función RPC)
      // Por seguridad, Supabase no permite borrar usuarios directamente
      // desde el cliente, así que usamos una función RPC (crear en Supabase SQL)
      await supabase.rpc('eliminar_usuario', params: {'uid': user.id});

      // 3️⃣ Cerrar sesión
      await supabase.auth.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cuenta eliminada correctamente.")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al eliminar cuenta: $e")));
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eliminar cuenta")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Eliminar cuenta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Esta acción eliminará tu cuenta y todos tus datos asociados.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isDeleting ? null : _eliminarCuenta,
                icon: const Icon(Icons.delete_forever),
                label: _isDeleting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Eliminar cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
