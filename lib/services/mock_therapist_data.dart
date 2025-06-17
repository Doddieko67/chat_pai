import 'package:pai_app/widgets/therapist_widgets.dart';
import 'package:pai_app/models/therapist_location.dart';
import 'package:pai_app/services/therapist_search_service.dart';

class MockTherapistData {
  // Datos mock de terapeutas con ubicaciones en Ciudad de México
  static List<TherapistWithDistance> getMockTherapistsWithLocations() {
    final therapists = [
      // Zona Roma Norte
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_001',
          name: 'Dra. María González',
          title: 'Psicóloga Clínica',
          specialties: 'Ansiedad, Depresión, Terapia Cognitiva',
          languages: ['Español', 'Inglés'],
          rating: 4.8,
          reviewCount: 124,
          experience: '8 años',
          pricePerSession: 850,
          availability: 'Disponible hoy',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en trastornos de ansiedad y depresión con enfoque cognitivo-conductual.',
          specialtyTags: ['Ansiedad', 'Depresión', 'Trauma'],
        ),
        location: TherapistLocation(
          therapistId: 'th_001',
          latitude: 19.4150,
          longitude: -99.1670,
          address: 'Av. Álvaro Obregón 151, Roma Norte',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '06700',
          consultoryName: 'Centro de Bienestar Mental',
          consultoryPhone: '+52 55 1234 5678',
          hasPhysicalConsultory: true,
          offersHomeVisits: true,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 15.0,
          geohash: '9g3w62e',
          workingHours: {
            'monday': {'isWorking': true, 'startTime': '09:00', 'endTime': '18:00'},
            'tuesday': {'isWorking': true, 'startTime': '09:00', 'endTime': '18:00'},
            'wednesday': {'isWorking': true, 'startTime': '09:00', 'endTime': '18:00'},
            'thursday': {'isWorking': true, 'startTime': '09:00', 'endTime': '18:00'},
            'friday': {'isWorking': true, 'startTime': '09:00', 'endTime': '17:00'},
            'saturday': {'isWorking': true, 'startTime': '10:00', 'endTime': '14:00'},
            'sunday': {'isWorking': false},
          },
        ),
        distanceKm: 2.3,
      ),

      // Zona Condesa
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_002',
          name: 'Dr. Carlos Mendoza',
          title: 'Psicoterapeuta',
          specialties: 'Terapia de Pareja, Terapia Familiar',
          languages: ['Español', 'Inglés', 'Francés'],
          rating: 4.6,
          reviewCount: 89,
          experience: '12 años',
          pricePerSession: 950,
          availability: 'Disponible mañana',
          isOnline: false,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en relaciones interpersonales y dinámicas familiares.',
          specialtyTags: ['Terapia de Pareja', 'Terapia Familiar', 'Comunicación'],
        ),
        location: TherapistLocation(
          therapistId: 'th_002',
          latitude: 19.4100,
          longitude: -99.1625,
          address: 'Av. Michoacán 78, Condesa',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '06140',
          consultoryName: 'Consultorio Mendoza',
          consultoryPhone: '+52 55 2345 6789',
          hasPhysicalConsultory: true,
          offersHomeVisits: false,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 0.0,
          geohash: '9g3w60h',
        ),
        distanceKm: 3.1,
      ),

      // Zona Polanco
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_003',
          name: 'Dra. Ana Rodríguez',
          title: 'Psiquiatra',
          specialties: 'Trastornos de Ansiedad, TDAH, Medicación',
          languages: ['Español', 'Inglés'],
          rating: 4.9,
          reviewCount: 156,
          experience: '15 años',
          pricePerSession: 1200,
          availability: 'Disponible esta semana',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1594824804732-ca8c6ac36d27?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Psiquiatra especializada en trastornos de ansiedad y tratamiento farmacológico.',
          specialtyTags: ['TDAH', 'Ansiedad', 'Medicación', 'Psiquiatría'],
        ),
        location: TherapistLocation(
          therapistId: 'th_003',
          latitude: 19.4326,
          longitude: -99.1909,
          address: 'Av. Presidente Masaryk 111, Polanco',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '11560',
          consultoryName: 'Clínica Polanco',
          consultoryPhone: '+52 55 3456 7890',
          hasPhysicalConsultory: true,
          offersHomeVisits: false,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 0.0,
          geohash: '9g3w8bx',
        ),
        distanceKm: 5.7,
      ),

      // Zona Del Valle
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_004',
          name: 'Lic. Roberto Silva',
          title: 'Psicólogo Deportivo',
          specialties: 'Psicología Deportiva, Motivación, Mindfulness',
          languages: ['Español', 'Inglés'],
          rating: 4.4,
          reviewCount: 67,
          experience: '6 años',
          pricePerSession: 700,
          availability: 'Disponible hoy',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en rendimiento deportivo y técnicas de mindfulness.',
          specialtyTags: ['Mindfulness', 'Deporte', 'Motivación'],
        ),
        location: TherapistLocation(
          therapistId: 'th_004',
          latitude: 19.3700,
          longitude: -99.1650,
          address: 'Eje 7 Sur 684, Del Valle',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '03100',
          consultoryName: 'Centro Integral del Valle',
          consultoryPhone: '+52 55 4567 8901',
          hasPhysicalConsultory: true,
          offersHomeVisits: true,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 20.0,
          geohash: '9g3vjq4',
        ),
        distanceKm: 7.2,
      ),

      // Zona Coyoacán
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_005',
          name: 'Dra. Patricia Hernández',
          title: 'Terapeuta Gestalt',
          specialties: 'Terapia Gestalt, Trauma, Duelo',
          languages: ['Español'],
          rating: 4.7,
          reviewCount: 98,
          experience: '10 años',
          pricePerSession: 800,
          availability: 'Disponible mañana',
          isOnline: false,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en terapia gestalt con enfoque en procesamiento de trauma.',
          specialtyTags: ['Trauma', 'Duelo', 'Gestalt'],
        ),
        location: TherapistLocation(
          therapistId: 'th_005',
          latitude: 19.3467,
          longitude: -99.1618,
          address: 'Av. Universidad 1321, Coyoacán',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '04000',
          consultoryName: 'Espacio Terapéutico Coyoacán',
          consultoryPhone: '+52 55 5678 9012',
          hasPhysicalConsultory: true,
          offersHomeVisits: false,
          offersOnlineConsultation: false,
          homeVisitRadiusKm: 0.0,
          geohash: '9g3vb4r',
        ),
        distanceKm: 9.8,
      ),

      // Zona Santa Fe
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_006',
          name: 'Dr. Miguel Torres',
          title: 'Psicólogo Organizacional',
          specialties: 'Estrés Laboral, Burnout, Coaching',
          languages: ['Español', 'Inglés', 'Portugués'],
          rating: 4.5,
          reviewCount: 112,
          experience: '9 años',
          pricePerSession: 1000,
          availability: 'Disponible esta semana',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1556157382-4e063bb5d9d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en psicología organizacional y manejo del estrés laboral.',
          specialtyTags: ['Estrés', 'Burnout', 'Coaching'],
        ),
        location: TherapistLocation(
          therapistId: 'th_006',
          latitude: 19.3570,
          longitude: -99.2590,
          address: 'Av. Vasco de Quiroga 2121, Santa Fe',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '01210',
          consultoryName: 'Torres Psychology Center',
          consultoryPhone: '+52 55 6789 0123',
          hasPhysicalConsultory: true,
          offersHomeVisits: false,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 0.0,
          geohash: '9g3s8cy',
        ),
        distanceKm: 12.5,
      ),

      // Zona Doctores (Centro)
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_007',
          name: 'Lic. Laura Martínez',
          title: 'Psicoterapeuta Infantil',
          specialties: 'Terapia Infantil, Adolescentes, Trastornos del Aprendizaje',
          languages: ['Español'],
          rating: 4.8,
          reviewCount: 78,
          experience: '7 años',
          pricePerSession: 650,
          availability: 'Disponible hoy',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en terapia infantil y adolescente con enfoque lúdico.',
          specialtyTags: ['Infantil', 'Adolescentes', 'Aprendizaje'],
        ),
        location: TherapistLocation(
          therapistId: 'th_007',
          latitude: 19.4200,
          longitude: -99.1430,
          address: 'Dr. Río de la Loza 300, Doctores',
          city: 'Ciudad de México',
          state: 'CDMX',
          country: 'México',
          postalCode: '06720',
          consultoryName: 'Centro Infantil Doctores',
          consultoryPhone: '+52 55 7890 1234',
          hasPhysicalConsultory: true,
          offersHomeVisits: true,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 25.0,
          geohash: '9g3w6c8',
        ),
        distanceKm: 4.1,
      ),

      // Online only therapist
      TherapistWithDistance(
        therapist: Therapist(
          id: 'th_008',
          name: 'Dra. Elena Vásquez',
          title: 'Psicóloga Online',
          specialties: 'Terapia Online, Ansiedad, Depresión Digital',
          languages: ['Español', 'Inglés', 'Italiano'],
          rating: 4.6,
          reviewCount: 203,
          experience: '5 años',
          pricePerSession: 550,
          availability: 'Disponible 24/7',
          isOnline: true,
          isVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          description: 'Especialista en terapia online y trastornos relacionados con la era digital.',
          specialtyTags: ['Online', 'Ansiedad', 'Digital'],
        ),
        location: TherapistLocation(
          therapistId: 'th_008',
          latitude: 0.0, // No tiene ubicación física
          longitude: 0.0,
          address: 'Consultas 100% Online',
          city: 'En línea',
          state: 'Virtual',
          country: 'México',
          hasPhysicalConsultory: false,
          offersHomeVisits: false,
          offersOnlineConsultation: true,
          homeVisitRadiusKm: 0.0,
          geohash: '',
        ),
        distanceKm: null, // No aplica distancia para online
      ),
    ];

    return therapists;
  }

  // Simular búsqueda por proximidad
  static Future<List<TherapistWithDistance>> searchNearbyMock({
    required double latitude,
    required double longitude,
    required double radiusKm,
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 800));

    final allTherapists = getMockTherapistsWithLocations();
    
    // Filtrar por distancia
    final nearbyTherapists = allTherapists.where((therapist) {
      if (therapist.location == null || therapist.distanceKm == null) return false;
      return therapist.distanceKm! <= radiusKm;
    }).toList();

    // Aplicar filtros adicionales si existen
    var filteredTherapists = nearbyTherapists;
    
    if (filters != null) {
      filteredTherapists = _applyFilters(filteredTherapists, filters);
    }

    // Ordenar por distancia
    filteredTherapists.sort((a, b) => 
      (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    return filteredTherapists.take(limit).toList();
  }

  // Simular búsqueda online
  static Future<List<TherapistWithDistance>> searchOnlineMock({
    TherapistSearchFilters? filters,
    int limit = 20,
  }) async {
    await Future.delayed(Duration(milliseconds: 600));

    final allTherapists = getMockTherapistsWithLocations();
    
    // Filtrar solo terapeutas que ofrecen consulta online
    var onlineTherapists = allTherapists.where((therapist) =>
      therapist.location?.offersOnlineConsultation == true).toList();

    if (filters != null) {
      onlineTherapists = _applyFilters(onlineTherapists, filters);
    }

    // Ordenar por rating
    onlineTherapists.sort((a, b) => 
      b.therapist.rating.compareTo(a.therapist.rating));

    return onlineTherapists.take(limit).toList();
  }

  // Aplicar filtros a lista de terapeutas
  static List<TherapistWithDistance> _applyFilters(
    List<TherapistWithDistance> therapists,
    TherapistSearchFilters filters,
  ) {
    return therapists.where((therapistWithDistance) {
      final therapist = therapistWithDistance.therapist;
      final location = therapistWithDistance.location;

      // Filtro por rating mínimo
      if (filters.minRating != null && therapist.rating < filters.minRating!) {
        return false;
      }

      // Filtro por precio máximo
      if (filters.maxPrice != null && therapist.pricePerSession > filters.maxPrice!) {
        return false;
      }

      // Filtro por especialidades
      if (filters.specialties?.isNotEmpty == true) {
        bool hasSpecialty = filters.specialties!.any((specialty) =>
          therapist.specialtyTags.contains(specialty) ||
          therapist.specialties.toLowerCase().contains(specialty.toLowerCase()));
        if (!hasSpecialty) return false;
      }

      // Filtro por idiomas
      if (filters.languages?.isNotEmpty == true) {
        bool hasLanguage = filters.languages!.any((lang) =>
          therapist.languages.contains(lang));
        if (!hasLanguage) return false;
      }

      // Filtro por tipo de consultorio
      if (filters.hasPhysicalConsultory != null &&
          location?.hasPhysicalConsultory != filters.hasPhysicalConsultory!) {
        return false;
      }

      if (filters.offersHomeVisits != null &&
          location?.offersHomeVisits != filters.offersHomeVisits!) {
        return false;
      }

      return true;
    }).toList();
  }
}