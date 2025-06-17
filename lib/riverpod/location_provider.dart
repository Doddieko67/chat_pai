import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pai_app/services/location_service.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

// Estado de ubicación
class LocationState {
  final LocationData? location;
  final bool isLoading;
  final String? error;
  final bool hasPermission;

  LocationState({
    this.location,
    this.isLoading = false,
    this.error,
    this.hasPermission = false,
  });

  LocationState copyWith({
    LocationData? location,
    bool? isLoading,
    String? error,
    bool? hasPermission,
  }) {
    return LocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

// Notificador de ubicación
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  // Obtener ubicación actual
  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Verificar permisos primero
      final hasPermission = await LocationService.checkAndRequestPermissions();
      
      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Permisos de ubicación denegados',
        );
        return;
      }

      // Obtener ubicación
      final location = await LocationService.getCurrentLocation();
      
      state = state.copyWith(
        location: location,
        isLoading: false,
        hasPermission: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasPermission: false,
      );
    }
  }

  // Obtener ubicación con configuraciones específicas
  Future<void> getCurrentLocationWithSettings({
    geolocator.LocationAccuracy accuracy = geolocator.LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
    bool includeAddress = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final hasPermission = await LocationService.checkAndRequestPermissions();
      
      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Permisos de ubicación denegados',
        );
        return;
      }

      final location = await LocationService.getCurrentLocationWithSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
        includeAddress: includeAddress,
      );
      
      state = state.copyWith(
        location: location,
        isLoading: false,
        hasPermission: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasPermission: false,
      );
    }
  }

  // Buscar ubicación por dirección
  Future<void> searchLocationByAddress(String address) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final locations = await LocationService.getLocationFromAddress(address);
      
      if (locations.isNotEmpty) {
        state = state.copyWith(
          location: locations.first,
          isLoading: false,
          hasPermission: true, // No necesita permisos para búsqueda por dirección
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró la dirección',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Establecer ubicación manualmente
  void setLocation(LocationData location) {
    state = state.copyWith(
      location: location,
      isLoading: false,
      error: null,
      hasPermission: true,
    );
  }

  // Limpiar ubicación
  void clearLocation() {
    state = LocationState();
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider principal de ubicación
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

// Provider para obtener ubicación automáticamente al inicializar
final autoLocationProvider = FutureProvider<LocationData?>((ref) async {
  try {
    await LocationService.checkAndRequestPermissions();
    return await LocationService.getCurrentLocation();
  } catch (e) {
    return null;
  }
});

// Provider para stream de ubicación en tiempo real
final locationStreamProvider = StreamProvider<LocationData>((ref) {
  return LocationService.getLocationStream(
    accuracy: geolocator.LocationAccuracy.high,
    distanceFilter: 50, // 50 metros
  );
});