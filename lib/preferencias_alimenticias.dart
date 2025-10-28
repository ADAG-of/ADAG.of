import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreferenciasScreen extends StatefulWidget {
  final String email;
  final String nombre;

  const PreferenciasScreen({
    super.key,
    required this.email,
    required this.nombre,
  });

  @override
  State<PreferenciasScreen> createState() => _PreferenciasScreenState();
}

class _PreferenciasScreenState extends State<PreferenciasScreen> {
  String? selectedDieta;
  List<String> selectedAlergias = [];
  bool _isLoading = false;

  final List<String> dietas = [
    "Vegano",
    "Vegetariano",
    "Keto",
    "Kosher",
    "Sin Azúcares",
    "Sin Carbohidratos"
  ];

  final Map<String, List<String>> alergiasPorCategoria = {
    "Proteínas": ["Pollo", "Pescado", "Huevo", "Carne de res", "Cerdo", "Mariscos"],
    "Frutos secos": ["Almendras", "Nueces", "Avellanas", "Pistachos", "Castañas"],
    "Origen vegetal": ["Lentejas", "Garbanzos", "Frijoles", "Trigo", "Maíz", "Soja"],
    "Frutas": ["Manzana", "Plátano", "Naranja", "Fresa", "Kiwi"],
    "Verduras": ["Lechuga", "Zanahoria", "Tomate", "Pepino", "Pimiento"],
    "Lácteos": ["Leche", "Queso", "Yogur", "Manteca"],
    "Semillas": ["Sésamo", "Chía", "Lino", "Girasol"],
  };

  Future<void> _guardarPreferencias() async {
    if (selectedDieta == null || selectedDieta!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una dieta antes de continuar.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final usuarioId = user?.id; // <-- Usar el ID autenticado

      if (usuarioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo obtener el usuario autenticado.")),
        );
        return;
      }

      final payload = {
        "usuario_id": usuarioId,
        "nombre_usuario": widget.nombre.isNotEmpty 
            ? widget.nombre 
            : widget.email.split('@').first,
        "dieta": selectedDieta,
        "alergias": selectedAlergias,
      };

      final response = await supabase
          .from("perfiles")
          .upsert(payload, onConflict: "usuario_id")
          .select();

      if (response.isEmpty) {
        throw Exception("No se pudo guardar el perfil.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Perfil guardado correctamente.")),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${error.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferencias Alimenticias"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Selecciona tu dieta:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedDieta,
                  hint: const Text("Elige una dieta"),
                  isExpanded: true,
                  items: dietas.map((dieta) {
                    return DropdownMenuItem(
                      value: dieta,
                      child: Text(dieta),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDieta = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text("Selecciona tus alergias:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...alergiasPorCategoria.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(entry.key),
                    children: entry.value.map((alergia) {
                      final isSelected = selectedAlergias.contains(alergia);
                      return CheckboxListTile(
                        title: Text(alergia),
                        value: isSelected,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              selectedAlergias.add(alergia);
                            } else {
                              selectedAlergias.remove(alergia);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardarPreferencias,
                  child: const Text("Guardar"),
                ),
              ],
            ),
    );
  }
}