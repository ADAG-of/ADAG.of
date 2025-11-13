import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _fallbackCoords = LatLng(-27.362137, -55.900875);
  LatLng? _currentCoords;
  LatLng? _selectedDestination;
  String? _selectedRestaurantName;
  String? _selectedRestaurantId;
  List<Marker> _restaurantMarkers = [];
  List<LatLng> _routePoints = [];
  double? _distanceKm;
  double? _durationMin;
  late final MapController _mapController;

  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMapData();
  }

  @override
  void dispose() {
    _positionStream = null;
    super.dispose();
  }

  Future<void> _loadMapData() async {
    await _getUserLocation();
    if (_currentCoords != null) {
      await _loadNearbyRestaurants();
      _startLocationUpdates();
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentCoords = _fallbackCoords);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentCoords = _fallbackCoords);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentCoords = _fallbackCoords);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentCoords = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadNearbyRestaurants() async {
    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];'
      'node(around:3000,${_currentCoords!.latitude},${_currentCoords!.longitude})[amenity=restaurant];out;',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final elements = data['elements'] as List;

      final markers = elements.map((e) {
        final lat = e['lat'];
        final lon = e['lon'];
        final id = e['id'].toString();
        final name = e['tags']?['name'] ?? 'Restaurante sin nombre';

        return Marker(
          point: LatLng(lat, lon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _selectedDestination = LatLng(lat, lon);
              _selectedRestaurantName = name;
              _selectedRestaurantId = id;
              _drawRouteTo(_selectedDestination!, name, id);
            },
            child: const Icon(Icons.restaurant, color: Colors.green, size: 35),
          ),
        );
      }).toList();

      setState(() => _restaurantMarkers = markers);
    }
  }

  /// 🔹 Guardar restaurante como favorito en Supabase
  Future<void> _addToFavorites(String restaurantId, String name) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para guardar favoritos.")),
      );
      return;
    }

    try {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'restaurant_id': restaurantId,
        'restaurant_name': name,
        'added_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurante agregado a favoritos ❤️")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar favorito: $e")),
      );
    }
  }

  /// 🔹 Calcular ruta y mostrar información
  Future<void> _drawRouteTo(LatLng destination, String name, String id) async {
    if (_currentCoords == null) return;

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${_currentCoords!.longitude},${_currentCoords!.latitude};'
      '${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0];
      final geometry = route['geometry']['coordinates'] as List;
      final distance = route['distance'] / 1000;
      final duration = route['duration'] / 60;

      final points = geometry
          .map((coords) => LatLng(coords[1], coords[0]))
          .toList()
          .cast<LatLng>();

      setState(() {
        _routePoints = points;
        _distanceKm = distance;
        _durationMin = duration;
      });

      _mapController.move(destination, 15);
      _showRouteInfoBottomSheet(name, id);
    }
  }

  void _showRouteInfoBottomSheet(String name, String restaurantId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_distanceKm != null && _durationMin != null)
                Text(
                  "Distancia: ${_distanceKm!.toStringAsFixed(2)} km — "
                  "Tiempo estimado: ${_durationMin!.toStringAsFixed(0)} min",
                  style: const TextStyle(fontSize: 16),
                ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _addToFavorites(restaurantId, name),
                  icon: const Icon(Icons.favorite_border, color: Colors.red, size: 32),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Seguir la posición del usuario
  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );

    _positionStream!.listen((Position position) {
      final newCoords = LatLng(position.latitude, position.longitude);
      setState(() => _currentCoords = newCoords);
      _mapController.move(newCoords, _mapController.camera.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Restaurantes"),
      ),
      body: _currentCoords == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCoords!,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentCoords!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                    ),
                    ..._restaurantMarkers,
                  ],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: Colors.red,
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
