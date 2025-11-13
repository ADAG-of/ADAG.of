import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestauranteScreen extends StatefulWidget {
  const RestauranteScreen({super.key});

  @override
  State<RestauranteScreen> createState() => _RestauranteScreenState();
}

class _RestauranteScreenState extends State<RestauranteScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        favorites = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('favorites')
          .select('restaurant_id, restaurant_name')
          .eq('user_id', user.id);

      setState(() {
        favorites = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar favoritos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = favorites.where((rest) {
      final name = rest['restaurant_name']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Restaurantes Favoritos"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    "Todavía no agregaste restaurantes a favoritos ❤️",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final rest = filtered[i];
                          return ListTile(
                            leading: const Icon(Icons.restaurant),
                            title: Text(rest['restaurant_name'] ?? 'Sin nombre'),
                            subtitle: Text("ID: ${rest['restaurant_id']}"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
