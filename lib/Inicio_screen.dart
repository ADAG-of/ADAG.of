import 'package:flutter/material.dart';
import 'restaurantes_screen.dart';
import 'map_screen.dart';

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final Map<String, String> restaurant = {
    'name': 'Mis Restaurantes Favoritos',
    'image': 'assets/images/anima.gif',
    'type': 'Comida variada',
  };

  String searchQuery = '';

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      // Quitamos el título porque ya no usás “Posadas”
      title: null,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔍 Search "falso" que abre el mapa
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text(
                    '¿A donde quieres ir a comer hoy?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),


            // ✅ Tarjeta centrada
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RestauranteScreen()),
                    );
                  },

                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75, // 👈 ancho estilo "PedidosYa"
                    height: 250,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.asset(
                                restaurant['image']!,
                                fit: BoxFit.cover, // 👈 ocupa todo el espacio sin bordes blancos
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  restaurant['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
