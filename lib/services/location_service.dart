import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}

class LocationService {
  static const String _permissionDeniedMessage = 'Permisos de ubicación denegados';
  static const String _permissionDeniedForeverMessage = 
      'Permisos de ubicación denegados permanentemente. Habilítalos en configuración.';
  static const String _locationDisabledMessage = 'Los servicios de ubicación están deshabilitados';

  // Verificar y solicitar permisos de ubicación
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(_locationDisabledMessage);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(_permissionDeniedMessage);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(_permissionDeniedForeverMessage);
    }

    return true;
  }

  // Obtener la ubicación actual del usuario
  static Future<LocationData> getCurrentLocation() async {
    await checkAndRequestPermissions();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      // Intentar obtener la dirección usando geocoding inverso
      String? address;
      String? city;
      String? country;
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street}, ${place.subLocality}, ${place.locality}';
          city = place.locality;
          country = place.country;
        }
      } catch (e) {
        print('Error obteniendo dirección: $e');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        country: country,
      );
    } catch (e) {
      throw Exception('Error obteniendo ubicación: ${e.toString()}');
    }
  }

  // Calcular distancia entre dos puntos en kilómetros
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  // Verificar si una ubicación está dentro de un radio específico
  static bool isWithinRadius(
    double userLat,
    double userLng,
    double targetLat,
    double targetLng,
    double radiusKm,
  ) {
    double distance = calculateDistance(userLat, userLng, targetLat, targetLng);
    return distance <= radiusKm;
  }

  // Obtener ubicación con opciones de configuración personalizadas
  static Future<LocationData> getCurrentLocationWithSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
    bool includeAddress = true,
  }) async {
    await checkAndRequestPermissions();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );

      String? address;
      String? city;
      String? country;
      
      if (includeAddress) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            address = _buildAddress(place);
            city = place.locality;
            country = place.country;
          }
        } catch (e) {
          print('Error obteniendo dirección: $e');
        }
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        country: country,
      );
    } catch (e) {
      throw Exception('Error obteniendo ubicación: ${e.toString()}');
    }
  }

  // Construir dirección legible desde un Placemark
  static String _buildAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    }
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }
    
    return addressParts.join(', ');
  }

  // Obtener ubicaciones desde dirección (geocoding)
  static Future<List<LocationData>> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      return locations.map((location) => LocationData(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
      )).toList();
    } catch (e) {
      throw Exception('Error buscando dirección: ${e.toString()}');
    }
  }

  // Stream para seguimiento de ubicación en tiempo real
  static Stream<LocationData> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // metros
  }) async* {
    await checkAndRequestPermissions();

    LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    await for (Position position in Geolocator.getPositionStream(
      locationSettings: locationSettings,
    )) {
      yield LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }
}