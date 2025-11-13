import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('favorites')
          .select('favorite_id, restaurant_id, added_at')
          .eq('user_id', user.id);

      setState(() {
        favorites = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando favoritos: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFavorite(int favoriteId) async {
    try {
      await supabase.from('favorites').delete().eq('favorite_id', favoriteId);
      setState(() {
        favorites.removeWhere((fav) => fav['favorite_id'] == favoriteId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurante eliminado de favoritos")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar favorito: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    "Todavía no agregaste restaurantes a favoritos",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final fav = favorites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text(
                          "Restaurante ID: ${fav['restaurant_id']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Agregado el: ${fav['added_at'] ?? 'Desconocido'}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.grey),
                          onPressed: () => _deleteFavorite(fav['favorite_id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
