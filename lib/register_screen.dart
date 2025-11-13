import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterScreen({required this.toggleTheme, Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

 Future<void> _registrarUsuario() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  setState(() => _isLoading = true);

  final supabase = Supabase.instance.client;
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final fullName = _nameController.text.trim();

  try {
    // Crear usuario en auth
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception("No se pudo obtener el usuario luego del registro.");
    }

    // Crear el perfil en la tabla 'perfiles'
    await supabase.from('perfiles').insert({
      'usuario_id': user.id,
      'nombre_usuario': fullName,
      'telefono': '',
      'direccion': '',
      'activo': true,
      'creado_en': DateTime.now().toIso8601String(),
      'actualizado_en': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta creada correctamente")),
      );
      Navigator.pushReplacementNamed(context, "/home");
    }
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Crear una cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un correo electrónico';
                    }
                    if (!emailRegex.hasMatch(value)) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value != null && value.length < 6
                      ? 'La contraseña debe tener al menos 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value != _passwordController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarUsuario,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Registrarse"),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
