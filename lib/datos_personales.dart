import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatosPersonalesPage extends StatefulWidget {
  const DatosPersonalesPage({Key? key}) : super(key: key);

  @override
  State<DatosPersonalesPage> createState() => _DatosPersonalesPageState();
}

class _DatosPersonalesPageState extends State<DatosPersonalesPage> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      final data = await supabase
          .from('perfiles')
          .select()
          .eq('usuario_id', user.id)
          .single();

      _nombreController.text = data['nombre_usuario'] ?? '';
      _telefonoController.text = data['teléfono'] ?? '';
      _direccionController.text = data['dirección'] ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar los datos: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      await supabase.from('perfiles').update({
        'nombre_usuario': _nombreController.text.trim(),
        'teléfono': _telefonoController.text.trim(),
        'dirección': _direccionController.text.trim(),
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('usuario_id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar cambios: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datos Personales"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: "Nombre completo",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: "Teléfono",
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: "Dirección",
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Guardar cambios"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
