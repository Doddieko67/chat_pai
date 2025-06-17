import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pai_app/services/location_service.dart';
import 'package:pai_app/services/therapist_search_service.dart';
import 'package:pai_app/models/therapist_location.dart';
import 'package:pai_app/widgets/therapist_widgets.dart';

class TherapistMapScreen extends ConsumerStatefulWidget {
  final LocationData? initialLocation;
  final double initialRadius;

  const TherapistMapScreen({
    Key? key,
    this.initialLocation,
    this.initialRadius = 10.0,
  }) : super(key: key);

  @override
  ConsumerState<TherapistMapScreen> createState() => _TherapistMapScreenState();
}

class _TherapistMapScreenState extends ConsumerState<TherapistMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  
  LocationData? _currentLocation;
  double _currentRadius = 10.0;
  List<TherapistWithDistance> _therapists = [];
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  TherapistWithDistance? _selectedTherapist;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationData location;
      
      if (widget.initialLocation != null) {
        location = widget.initialLocation!;
      } else {
        // Intentar obtener ubicación actual
        try {
          await LocationService.checkAndRequestPermissions();
          location = await LocationService.getCurrentLocation();
          _hasLocationPermission = true;
        } catch (e) {
          // Si no hay permisos, usar ubicación por defecto (Ciudad de México)
          location = LocationData(
            latitude: 19.4326,
            longitude: -99.1332,
            address: 'Ciudad de México, CDMX, México',
            city: 'Ciudad de México',
            country: 'México',
          );
          _hasLocationPermission = false;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usando ubicación por defecto. $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      _currentLocation = location;
      await _searchTherapists();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inicializando mapa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchTherapists() async {
    if (_currentLocation == null) return;

    setState(() => _isLoading = true);

    try {
      final searchService = TherapistSearchService();
      final results = await searchService.searchNearby(
        userLocation: _currentLocation!,
        radiusKm: _currentRadius,
        limit: 50,
      );

      _therapists = results;
      _updateMarkers();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error buscando terapeutas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarkers() {
    _markers.clear();
    _circles.clear();

    if (_currentLocation != null) {
      // Marcador de ubicación del usuario
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Tu ubicación',
            snippet: _currentLocation!.address ?? 'Ubicación actual',
          ),
        ),
      );

      // Círculo del radio de búsqueda
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          radius: _currentRadius * 1000, // Convertir km a metros
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          strokeColor: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
        ),
      );
    }

    // Marcadores de terapeutas
    for (int i = 0; i < _therapists.length; i++) {
      final therapistWithDistance = _therapists[i];
      final location = therapistWithDistance.location;
      
      if (location != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('therapist_${therapistWithDistance.therapist.id}'),
            position: LatLng(location.latitude, location.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: therapistWithDistance.therapist.name,
              snippet: '${therapistWithDistance.distanceKm?.toStringAsFixed(1)} km - \$${therapistWithDistance.therapist.pricePerSession.toInt()}',
            ),
            onTap: () => _selectTherapist(therapistWithDistance),
          ),
        );
      }
    }

    setState(() {});
  }

  void _selectTherapist(TherapistWithDistance therapistWithDistance) {
    setState(() {
      _selectedTherapist = therapistWithDistance;
    });
    
    _showTherapistBottomSheet(therapistWithDistance);
  }

  void _showTherapistBottomSheet(TherapistWithDistance therapistWithDistance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Indicador de arrastre
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Información del terapeuta
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTherapistHeader(therapistWithDistance),
                      const SizedBox(height: 16),
                      _buildLocationInfo(therapistWithDistance.location!),
                      const SizedBox(height: 16),
                      _buildConsultationOptions(therapistWithDistance.location!),
                      const SizedBox(height: 24),
                      _buildActionButtons(therapistWithDistance),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTherapistHeader(TherapistWithDistance therapistWithDistance) {
    final therapist = therapistWithDistance.therapist;
    
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(therapist.imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                therapist.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                therapist.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(' ${therapist.rating} (${therapist.reviewCount})'),
                  const SizedBox(width: 8),
                  if (therapistWithDistance.distanceKm != null)
                    Text(
                      '• ${therapistWithDistance.distanceKm!.toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${therapist.pricePerSession.toInt()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'por sesión',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo(TherapistLocation location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location.fullAddress,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        if (location.consultoryName?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.business, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                location.consultoryName!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConsultationOptions(TherapistLocation location) {
    final options = location.availableConsultationTypes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modalidades disponibles',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) => Chip(
            label: Text(option),
            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TherapistWithDistance therapistWithDistance) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDirections(therapistWithDistance.location!);
            },
            icon: const Icon(Icons.directions),
            label: const Text('Cómo llegar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _bookAppointment(therapistWithDistance.therapist);
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar'),
          ),
        ),
      ],
    );
  }

  void _showDirections(TherapistLocation location) {
    // TODO: Implementar navegación a Google Maps o Apple Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo direcciones a ${location.fullAddress}'),
      ),
    );
  }

  void _bookAppointment(Therapist therapist) {
    // TODO: Navegar a pantalla de agendamiento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendando cita con ${therapist.name}'),
      ),
    );
  }

  void _showRadiusSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Radio de búsqueda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Slider(
              value: _currentRadius,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              label: '${_currentRadius.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _currentRadius = value;
                });
              },
            ),
            Text('${_currentRadius.toInt()} kilómetros'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _searchTherapists();
                    },
                    child: const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terapeutas Cercanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showRadiusSelector,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _hasLocationPermission ? _initializeLocation : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentLocation == null
              ? const Center(
                  child: Text('No se pudo obtener la ubicación'),
                )
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                    ),
                    zoom: 13.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: _hasLocationPermission,
                  myLocationButtonEnabled: false, // Usamos nuestro botón personalizado
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'list_view',
            mini: true,
            onPressed: () {
              Navigator.pop(context, _therapists);
            },
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: _searchTherapists,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}