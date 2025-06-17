import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pai_app/services/therapist_search_service.dart';
import 'package:pai_app/services/location_service.dart';
import 'package:pai_app/widgets/therapist_widgets.dart';

// Estado de búsqueda de terapeutas
class TherapistSearchState {
  final List<TherapistWithDistance> therapists;
  final bool isLoading;
  final String? error;
  final TherapistSearchFilters? currentFilters;
  final LocationData? searchLocation;
  final int totalResults;

  TherapistSearchState({
    this.therapists = const [],
    this.isLoading = false,
    this.error,
    this.currentFilters,
    this.searchLocation,
    this.totalResults = 0,
  });

  TherapistSearchState copyWith({
    List<TherapistWithDistance>? therapists,
    bool? isLoading,
    String? error,
    TherapistSearchFilters? currentFilters,
    LocationData? searchLocation,
    int? totalResults,
  }) {
    return TherapistSearchState(
      therapists: therapists ?? this.therapists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilters: currentFilters ?? this.currentFilters,
      searchLocation: searchLocation ?? this.searchLocation,
      totalResults: totalResults ?? this.totalResults,
    );
  }
}

// Notificador de búsqueda de terapeutas
class TherapistSearchNotifier extends StateNotifier<TherapistSearchState> {
  final TherapistSearchService _searchService = TherapistSearchService();

  TherapistSearchNotifier() : super(TherapistSearchState());

  // Buscar terapeutas cerca de una ubicación
  Future<void> searchNearby({
    required LocationData location,
    required double radiusKm,
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchLocation: location,
      currentFilters: filters,
    );

    try {
      final results = await _searchService.searchNearby(
        userLocation: location,
        radiusKm: radiusKm,
        filters: filters,
        limit: limit,
      );

      state = state.copyWith(
        therapists: results,
        isLoading: false,
        totalResults: results.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Buscar terapeutas en una ciudad
  Future<void> searchInCity({
    required String city,
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentFilters: filters,
    );

    try {
      final results = await _searchService.searchInCity(
        city: city,
        filters: filters,
        limit: limit,
      );

      state = state.copyWith(
        therapists: results,
        isLoading: false,
        totalResults: results.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Buscar terapeutas online
  Future<void> searchOnlineTherapists({
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentFilters: filters,
    );

    try {
      final results = await _searchService.searchOnlineTherapists(
        filters: filters,
        limit: limit,
      );

      state = state.copyWith(
        therapists: results,
        isLoading: false,
        totalResults: results.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Aplicar filtros a la búsqueda actual
  Future<void> applyFilters(TherapistSearchFilters filters) async {
    if (state.searchLocation != null) {
      await searchNearby(
        location: state.searchLocation!,
        radiusKm: filters.maxDistance ?? 10.0,
        filters: filters,
      );
    } else {
      await searchOnlineTherapists(filters: filters);
    }
  }

  // Ordenar resultados
  void sortResults(String sortBy) {
    final sortedTherapists = List<TherapistWithDistance>.from(state.therapists);

    switch (sortBy) {
      case 'distance':
        sortedTherapists.sort((a, b) => 
          (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
        break;
      case 'rating':
        sortedTherapists.sort((a, b) => 
          b.therapist.rating.compareTo(a.therapist.rating));
        break;
      case 'price_asc':
        sortedTherapists.sort((a, b) => 
          a.therapist.pricePerSession.compareTo(b.therapist.pricePerSession));
        break;
      case 'price_desc':
        sortedTherapists.sort((a, b) => 
          b.therapist.pricePerSession.compareTo(a.therapist.pricePerSession));
        break;
      case 'experience':
        sortedTherapists.sort((a, b) {
          int expA = int.tryParse(a.therapist.experience.split(' ')[0]) ?? 0;
          int expB = int.tryParse(b.therapist.experience.split(' ')[0]) ?? 0;
          return expB.compareTo(expA);
        });
        break;
    }

    state = state.copyWith(therapists: sortedTherapists);
  }

  // Filtrar por texto
  void filterByText(String query) {
    if (query.isEmpty) {
      return; // No filtrar si no hay query
    }

    final filtered = state.therapists.where((therapistWithDistance) {
      final therapist = therapistWithDistance.therapist;
      final searchText = query.toLowerCase();
      
      return therapist.name.toLowerCase().contains(searchText) ||
             therapist.title.toLowerCase().contains(searchText) ||
             therapist.specialties.toLowerCase().contains(searchText) ||
             therapist.specialtyTags.any((tag) => 
               tag.toLowerCase().contains(searchText)) ||
             therapist.languages.any((lang) => 
               lang.toLowerCase().contains(searchText));
    }).toList();

    state = state.copyWith(therapists: filtered);
  }

  // Limpiar búsqueda
  void clearSearch() {
    state = TherapistSearchState();
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Obtener terapeutas favoritos (simulado)
  List<TherapistWithDistance> getFavoriteTherapists() {
    // TODO: Implementar lógica de favoritos desde Firestore
    return state.therapists.where((t) => t.therapist.rating >= 4.5).toList();
  }
}

// Provider principal de búsqueda de terapeutas
final therapistSearchProvider = StateNotifierProvider<TherapistSearchNotifier, TherapistSearchState>((ref) {
  return TherapistSearchNotifier();
});

// Provider para filtros de búsqueda
final searchFiltersProvider = StateProvider<TherapistSearchFilters?>((ref) => null);

// Provider para el radio de búsqueda
final searchRadiusProvider = StateProvider<double>((ref) => 10.0);

// Provider para el tipo de búsqueda actual
final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.nearby);

// Provider para el texto de búsqueda
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider para orden de resultados
final sortOrderProvider = StateProvider<String>((ref) => 'distance');

// Enum para tipos de búsqueda
enum SearchType {
  nearby,
  city,
  online,
}

// Provider combinado para búsqueda automática
final autoSearchProvider = FutureProvider<List<TherapistWithDistance>>((ref) async {
  final searchType = ref.watch(searchTypeProvider);
  final filters = ref.watch(searchFiltersProvider);
  final radius = ref.watch(searchRadiusProvider);
  
  final searchService = TherapistSearchService();

  switch (searchType) {
    case SearchType.nearby:
      // Necesita ubicación del usuario
      try {
        await LocationService.checkAndRequestPermissions();
        final location = await LocationService.getCurrentLocation();
        return await searchService.searchNearby(
          userLocation: location,
          radiusKm: radius,
          filters: filters,
        );
      } catch (e) {
        return [];
      }
    
    case SearchType.city:
      // Buscar en ciudad por defecto (Ciudad de México)
      return await searchService.searchInCity(
        city: 'Ciudad de México',
        filters: filters,
      );
    
    case SearchType.online:
      return await searchService.searchOnlineTherapists(
        filters: filters,
      );
  }
});

// Provider para estadísticas de búsqueda
final searchStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final searchState = ref.watch(therapistSearchProvider);
  
  if (searchState.therapists.isEmpty) {
    return {
      'total': 0,
      'averageRating': 0.0,
      'averagePrice': 0.0,
      'averageDistance': 0.0,
      'onlineCount': 0,
      'physicalCount': 0,
    };
  }

  final therapists = searchState.therapists;
  final total = therapists.length;
  
  final averageRating = therapists
      .map((t) => t.therapist.rating)
      .reduce((a, b) => a + b) / total;
  
  final averagePrice = therapists
      .map((t) => t.therapist.pricePerSession)
      .reduce((a, b) => a + b) / total;
  
  final distances = therapists
      .where((t) => t.distanceKm != null)
      .map((t) => t.distanceKm!)
      .toList();
  
  final averageDistance = distances.isNotEmpty
      ? distances.reduce((a, b) => a + b) / distances.length
      : 0.0;
  
  final onlineCount = therapists
      .where((t) => t.location?.offersOnlineConsultation == true)
      .length;
  
  final physicalCount = therapists
      .where((t) => t.location?.hasPhysicalConsultory == true)
      .length;

  return {
    'total': total,
    'averageRating': averageRating,
    'averagePrice': averagePrice,
    'averageDistance': averageDistance,
    'onlineCount': onlineCount,
    'physicalCount': physicalCount,
  };
});