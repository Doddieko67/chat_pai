import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pai_app/services/location_service.dart';

class TherapistLocation {
  final String therapistId;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final String? consultoryName;
  final String? consultoryPhone;
  final bool hasPhysicalConsultory;
  final bool offersHomeVisits;
  final bool offersOnlineConsultation;
  final double homeVisitRadiusKm;
  final String geohash; // Para búsquedas eficientes en Firestore
  final Map<String, dynamic>? workingHours;

  TherapistLocation({
    required this.therapistId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
    this.consultoryName,
    this.consultoryPhone,
    required this.hasPhysicalConsultory,
    required this.offersHomeVisits,
    required this.offersOnlineConsultation,
    this.homeVisitRadiusKm = 10.0,
    required this.geohash,
    this.workingHours,
  });

  // Crear desde Map (Firestore)
  factory TherapistLocation.fromMap(Map<String, dynamic> map) {
    final geoPoint = map['geopoint'] as GeoPoint?;
    
    return TherapistLocation(
      therapistId: map['therapistId'] ?? '',
      latitude: geoPoint?.latitude ?? 0.0,
      longitude: geoPoint?.longitude ?? 0.0,
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postalCode'],
      consultoryName: map['consultoryName'],
      consultoryPhone: map['consultoryPhone'],
      hasPhysicalConsultory: map['hasPhysicalConsultory'] ?? false,
      offersHomeVisits: map['offersHomeVisits'] ?? false,
      offersOnlineConsultation: map['offersOnlineConsultation'] ?? true,
      homeVisitRadiusKm: (map['homeVisitRadiusKm'] ?? 10.0).toDouble(),
      geohash: map['geohash'] ?? '',
      workingHours: map['workingHours'],
    );
  }

  // Convertir a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'therapistId': therapistId,
      'geopoint': GeoPoint(latitude, longitude),
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'consultoryName': consultoryName,
      'consultoryPhone': consultoryPhone,
      'hasPhysicalConsultory': hasPhysicalConsultory,
      'offersHomeVisits': offersHomeVisits,
      'offersOnlineConsultation': offersOnlineConsultation,
      'homeVisitRadiusKm': homeVisitRadiusKm,
      'geohash': geohash,
      'workingHours': workingHours,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Calcular distancia desde la ubicación del usuario
  double distanceFromUser(LocationData userLocation) {
    return LocationService.calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      latitude,
      longitude,
    );
  }

  // Verificar si está dentro del radio de visitas a domicilio
  bool canVisitHome(LocationData userLocation) {
    if (!offersHomeVisits) return false;
    return distanceFromUser(userLocation) <= homeVisitRadiusKm;
  }

  // Obtener dirección completa formateada
  String get fullAddress {
    List<String> addressParts = [address];
    if (city.isNotEmpty) addressParts.add(city);
    if (state.isNotEmpty) addressParts.add(state);
    if (country.isNotEmpty) addressParts.add(country);
    if (postalCode?.isNotEmpty == true) addressParts.add(postalCode!);
    
    return addressParts.join(', ');
  }

  // Obtener información del consultorio
  String get consultoryInfo {
    if (!hasPhysicalConsultory) return 'Solo consultas online';
    
    String info = consultoryName?.isNotEmpty == true 
        ? consultoryName! 
        : 'Consultorio';
    
    if (consultoryPhone?.isNotEmpty == true) {
      info += ' - Tel: $consultoryPhone';
    }
    
    return info;
  }

  // Obtener opciones de consulta disponibles
  List<String> get availableConsultationTypes {
    List<String> types = [];
    
    if (hasPhysicalConsultory) types.add('Presencial');
    if (offersHomeVisits) types.add('Domicilio');
    if (offersOnlineConsultation) types.add('Online');
    
    return types;
  }

  // Verificar si está disponible en un día y hora específicos
  bool isAvailableAt(DateTime dateTime) {
    if (workingHours == null) return true; // Asume disponibilidad si no hay horarios definidos
    
    String dayOfWeek = _getDayOfWeek(dateTime.weekday);
    Map<String, dynamic>? daySchedule = workingHours![dayOfWeek];
    
    if (daySchedule == null || daySchedule['isWorking'] != true) {
      return false;
    }
    
    String currentTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    String? startTime = daySchedule['startTime'];
    String? endTime = daySchedule['endTime'];
    
    if (startTime == null || endTime == null) return true;
    
    return currentTime.compareTo(startTime) >= 0 && 
           currentTime.compareTo(endTime) <= 0;
  }

  String _getDayOfWeek(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  // Copia con modificaciones
  TherapistLocation copyWith({
    String? therapistId,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? consultoryName,
    String? consultoryPhone,
    bool? hasPhysicalConsultory,
    bool? offersHomeVisits,
    bool? offersOnlineConsultation,
    double? homeVisitRadiusKm,
    String? geohash,
    Map<String, dynamic>? workingHours,
  }) {
    return TherapistLocation(
      therapistId: therapistId ?? this.therapistId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      consultoryName: consultoryName ?? this.consultoryName,
      consultoryPhone: consultoryPhone ?? this.consultoryPhone,
      hasPhysicalConsultory: hasPhysicalConsultory ?? this.hasPhysicalConsultory,
      offersHomeVisits: offersHomeVisits ?? this.offersHomeVisits,
      offersOnlineConsultation: offersOnlineConsultation ?? this.offersOnlineConsultation,
      homeVisitRadiusKm: homeVisitRadiusKm ?? this.homeVisitRadiusKm,
      geohash: geohash ?? this.geohash,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  @override
  String toString() {
    return 'TherapistLocation(id: $therapistId, address: $address, distance: ${latitude}°, ${longitude}°)';
  }
}