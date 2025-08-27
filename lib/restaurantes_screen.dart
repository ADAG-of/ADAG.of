import 'package:flutter/material.dart';
import 'restaurant_detail_screen.dart';
import 'map_screen.dart';


class RestauranteScreen extends StatefulWidget {
  @override
  _RestauranteScreenState createState() => _RestauranteScreenState();
}

class _RestauranteScreenState extends State<RestauranteScreen> {
  final List<Map<String, String>> restaurants = [
    {
      'name': 'Nomades',
      'image': 'assets/images/nomades.png',
      'type': 'Comida Japonesa'
    },
    {
      'name': 'Bocatto',
      'image': 'assets/images/bocatto.png',
      'type': 'Variado'
    },
    {
      'name': 'Pizza40',
      'image': 'assets/images/Pizza40.png',
      'type': 'Comida Italiana,Variado'
    },
    {
      'name': 'Mendieta',
      'image': 'assets/images/mendieta.png',
      'type': 'Variado'
    },
    {
      'name': 'The Rox',
      'image': 'assets/images/the_rox.png',
      'type': 'Variado'
    },
    {
      'name': 'Holy',
      'image': 'assets/images/Holy.png',
      'type': 'Variado'
    },
  ];

  final Set<int> favoriteIndexes = {};
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = restaurants.asMap().entries
        .where((entry) {
          final name = entry.value['name']!.toLowerCase();
          final type = entry.value['type']!.toLowerCase();
          return name.contains(searchQuery.toLowerCase()) ||
              type.contains(searchQuery.toLowerCase());
        })
        .map((entry) => {'index': entry.key, 'data': entry.value})
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Align(
  alignment: Alignment.centerLeft,
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    },
  ),
)
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 Campo de búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Que quieres comer hoy?',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 📋 Lista filtrada
            Expanded(
              child: GridView.builder(
                itemCount: filteredRestaurants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.98, 
                ),
                itemBuilder: (context, i) {
                  final index = filteredRestaurants[i]['index'] as int;
                  final restaurant =
                      filteredRestaurants[i]['data'] as Map<String, String>;
                  final isFavorite = favoriteIndexes.contains(index);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            name: restaurant['name']!,
                            image: restaurant['image']!,
                            type: restaurant['type']!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              restaurant['image']!,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  restaurant['name']!,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurant['type']!,
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isFavorite) {
                                        favoriteIndexes.remove(index);
                                      } else {
                                        favoriteIndexes.add(index);
                                      }
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
