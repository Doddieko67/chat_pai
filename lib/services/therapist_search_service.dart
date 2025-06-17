import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:pai_app/models/therapist_location.dart';
import 'package:pai_app/services/location_service.dart';
import 'package:pai_app/services/mock_therapist_data.dart';
import 'package:pai_app/widgets/therapist_widgets.dart';

class TherapistSearchFilters {
  final double? maxDistance; // en kilómetros
  final List<String>? specialties;
  final double? minRating;
  final double? maxPrice;
  final List<String>? languages;
  final bool? isOnline;
  final bool? acceptsInsurance;
  final bool? hasPhysicalConsultory;
  final bool? offersHomeVisits;
  final String? availability; // 'today', 'this_week', 'this_month'

  TherapistSearchFilters({
    this.maxDistance,
    this.specialties,
    this.minRating,
    this.maxPrice,
    this.languages,
    this.isOnline,
    this.acceptsInsurance,
    this.hasPhysicalConsultory,
    this.offersHomeVisits,
    this.availability,
  });
}

class TherapistWithDistance {
  final Therapist therapist;
  final TherapistLocation? location;
  final double? distanceKm;

  TherapistWithDistance({
    required this.therapist,
    this.location,
    this.distanceKm,
  });
}

class TherapistSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final _geofire = GeoCollectionReference(_firestore.collection('therapist_locations'));
  
  // Flag para usar datos mock en desarrollo
  final bool _useMockData = true; // Cambiar a false para usar Firestore real

  // Buscar terapeutas cerca de una ubicación específica
  Future<List<TherapistWithDistance>> searchNearby({
    required LocationData userLocation,
    required double radiusKm,
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    if (_useMockData) {
      return MockTherapistData.searchNearbyMock(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusKm: radiusKm,
        filters: filters,
        limit: limit,
      );
    }

    try {
      // Crear consulta geoespacial
      final center = GeoFirePoint(GeoPoint(userLocation.latitude, userLocation.longitude));
      
      // Obtener ubicaciones de terapeutas dentro del radio
      final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> locationsStream = 
          _geofire.subscribeWithin(
            center: center,
            radiusInKm: radiusKm,
            field: 'geopoint',
            geopointFrom: (data) => data['geopoint'] as GeoPoint,
            strictMode: true,
          );

      // Obtener la primera emisión del stream
      final locationDocs = await locationsStream.first;
      
      if (locationDocs.isEmpty) {
        return [];
      }

      // Extraer IDs de terapeutas
      final therapistIds = locationDocs
          .map((doc) => doc.data()?['therapistId'] as String)
          .where((id) => id.isNotEmpty)
          .toList();

      if (therapistIds.isEmpty) {
        return [];
      }

      // Obtener datos de terapeutas
      final therapistsQuery = await _firestore
          .collection('therapists')
          .where(FieldPath.documentId, whereIn: therapistIds.take(10).toList()) // Firestore limit
          .get();

      List<TherapistWithDistance> results = [];

      for (var therapistDoc in therapistsQuery.docs) {
        try {
          // Encontrar la ubicación correspondiente
          final locationDoc = locationDocs.firstWhere(
            (loc) => loc.data()?['therapistId'] == therapistDoc.id,
            orElse: () => throw StateError('Location not found'),
          );

          final therapistLocation = TherapistLocation.fromMap(locationDoc.data()!);
          
          // Calcular distancia real
          final distance = therapistLocation.distanceFromUser(userLocation);
          
          // Crear objeto Therapist desde los datos
          final therapist = _createTherapistFromData(therapistDoc.id, therapistDoc.data());
          
          // Aplicar filtros adicionales
          if (_passesFilters(therapist, therapistLocation, filters)) {
            results.add(TherapistWithDistance(
              therapist: therapist,
              location: therapistLocation,
              distanceKm: distance,
            ));
          }
        } catch (e) {
          print('Error procesando terapeuta ${therapistDoc.id}: $e');
          continue;
        }
      }

      // Ordenar por distancia
      results.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
      
      return results.take(limit).toList();
      
    } catch (e) {
      throw Exception('Error buscando terapeutas: ${e.toString()}');
    }
  }

  // Buscar terapeutas en una ciudad específica
  Future<List<TherapistWithDistance>> searchInCity({
    required String city,
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    try {
      final locationsQuery = await _firestore
          .collection('therapist_locations')
          .where('city', isEqualTo: city)
          .limit(limit)
          .get();

      List<TherapistWithDistance> results = [];

      for (var locationDoc in locationsQuery.docs) {
        try {
          final therapistLocation = TherapistLocation.fromMap(locationDoc.data());
          
          // Obtener datos del terapeuta
          final therapistDoc = await _firestore
              .collection('therapists')
              .doc(therapistLocation.therapistId)
              .get();

          if (!therapistDoc.exists) continue;

          final therapist = _createTherapistFromData(therapistDoc.id, therapistDoc.data()!);
          
          if (_passesFilters(therapist, therapistLocation, filters)) {
            results.add(TherapistWithDistance(
              therapist: therapist,
              location: therapistLocation,
            ));
          }
        } catch (e) {
          print('Error procesando terapeuta en ciudad: $e');
          continue;
        }
      }

      // Ordenar por rating
      results.sort((a, b) => b.therapist.rating.compareTo(a.therapist.rating));
      
      return results;
      
    } catch (e) {
      throw Exception('Error buscando terapeutas en ciudad: ${e.toString()}');
    }
  }

  // Buscar terapeutas online (sin restricción geográfica)
  Future<List<TherapistWithDistance>> searchOnlineTherapists({
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    if (_useMockData) {
      return MockTherapistData.searchOnlineMock(
        filters: filters,
        limit: limit,
      );
    }

    try {
      Query query = _firestore.collection('therapists');
      
      // Aplicar filtros básicos
      if (filters?.specialties?.isNotEmpty == true) {
        query = query.where('specialties', arrayContainsAny: filters!.specialties);
      }
      
      if (filters?.minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: filters!.minRating);
      }
      
      if (filters?.maxPrice != null) {
        query = query.where('pricePerSession', isLessThanOrEqualTo: filters!.maxPrice);
      }

      // Aplicar límite
      query = query.limit(limit);
      
      final therapistsQuery = await query.get();
      
      List<TherapistWithDistance> results = [];

      for (var therapistDoc in therapistsQuery.docs) {
        try {
          final therapist = _createTherapistFromData(therapistDoc.id, therapistDoc.data() as Map<String, dynamic>);
          
          // Verificar si ofrece consultas online
          final locationDoc = await _firestore
              .collection('therapist_locations')
              .where('therapistId', isEqualTo: therapistDoc.id)
              .where('offersOnlineConsultation', isEqualTo: true)
              .limit(1)
              .get();

          if (locationDoc.docs.isNotEmpty) {
            final location = TherapistLocation.fromMap(locationDoc.docs.first.data());
            
            if (_passesFilters(therapist, location, filters)) {
              results.add(TherapistWithDistance(
                therapist: therapist,
                location: location,
              ));
            }
          }
        } catch (e) {
          print('Error procesando terapeuta online: $e');
          continue;
        }
      }

      return results;
      
    } catch (e) {
      throw Exception('Error buscando terapeutas online: ${e.toString()}');
    }
  }

  // Crear objeto Therapist desde datos de Firestore
  Therapist _createTherapistFromData(String id, Map<String, dynamic> data) {
    return Therapist(
      id: id,
      name: data['name'] ?? 'Terapeuta',
      title: data['title'] ?? 'Psicólogo',
      specialties: data['specialties'] ?? 'Terapia General',
      languages: List<String>.from(data['languages'] ?? ['Español']),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      experience: data['experience'] ?? '1 año',
      pricePerSession: (data['pricePerSession'] ?? 0).toDouble(),
      availability: data['availability'] ?? 'Disponible',
      isOnline: data['isOnline'] ?? false,
      isVerified: data['isVerified'] ?? false,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      description: data['description'] ?? 'Descripción no disponible',
      specialtyTags: List<String>.from(data['specialtyTags'] ?? []),
    );
  }

  // Verificar si un terapeuta pasa los filtros aplicados
  bool _passesFilters(
    Therapist therapist, 
    TherapistLocation location, 
    TherapistSearchFilters? filters,
  ) {
    if (filters == null) return true;

    if (filters.minRating != null && therapist.rating < filters.minRating!) {
      return false;
    }

    if (filters.maxPrice != null && therapist.pricePerSession > filters.maxPrice!) {
      return false;
    }

    if (filters.languages?.isNotEmpty == true) {
      bool hasLanguage = filters.languages!.any(
        (lang) => therapist.languages.contains(lang),
      );
      if (!hasLanguage) return false;
    }

    if (filters.specialties?.isNotEmpty == true) {
      bool hasSpecialty = filters.specialties!.any(
        (specialty) => therapist.specialtyTags.contains(specialty) ||
                      therapist.specialties.toLowerCase().contains(specialty.toLowerCase()),
      );
      if (!hasSpecialty) return false;
    }

    if (filters.hasPhysicalConsultory != null && 
        location.hasPhysicalConsultory != filters.hasPhysicalConsultory!) {
      return false;
    }

    if (filters.offersHomeVisits != null && 
        location.offersHomeVisits != filters.offersHomeVisits!) {
      return false;
    }

    return true;
  }

  // Obtener ubicación de un terapeuta específico
  Future<TherapistLocation?> getTherapistLocation(String therapistId) async {
    try {
      final locationQuery = await _firestore
          .collection('therapist_locations')
          .where('therapistId', isEqualTo: therapistId)
          .limit(1)
          .get();

      if (locationQuery.docs.isNotEmpty) {
        return TherapistLocation.fromMap(locationQuery.docs.first.data());
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo ubicación del terapeuta: $e');
      return null;
    }
  }

  // Agregar o actualizar ubicación de terapeuta
  Future<void> updateTherapistLocation(TherapistLocation location) async {
    try {
      await _firestore
          .collection('therapist_locations')
          .doc(location.therapistId)
          .set(location.toMap());
    } catch (e) {
      throw Exception('Error actualizando ubicación del terapeuta: ${e.toString()}');
    }
  }
}