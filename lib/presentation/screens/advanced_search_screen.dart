import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pai_app/riverpod/location_provider.dart';
import 'package:pai_app/riverpod/therapist_search_provider.dart';
import 'package:pai_app/services/therapist_search_service.dart';
import 'package:pai_app/services/location_service.dart';
import 'package:pai_app/widgets/therapist_widgets.dart';
import 'package:pai_app/presentation/screens/therapist_map_screen.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  
  // Filtros
  double _maxDistance = 10.0;
  List<String> _selectedSpecialties = [];
  double _minRating = 0.0;
  RangeValues _priceRange = RangeValues(0, 300);
  List<String> _selectedLanguages = [];
  bool _onlineOnly = false;
  bool _hasPhysicalConsultory = false;
  bool _offersHomeVisits = false;
  String _availability = '';

  // Opciones disponibles
  final List<String> _availableSpecialties = [
    'Ansiedad',
    'Depresión',
    'Terapia de Pareja',
    'Terapia Familiar',
    'Trauma',
    'Trastornos Alimentarios',
    'TDAH',
    'Terapia Cognitiva',
    'Mindfulness',
    'Adicciones',
  ];

  final List<String> _availableLanguages = [
    'Español',
    'Inglés',
    'Francés',
    'Portugués',
    'Italiano',
  ];

  final List<String> _availabilityOptions = [
    'Hoy',
    'Esta semana',
    'Este mes',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationState = ref.read(locationProvider);
      if (locationState.location != null) {
        _locationController.text = locationState.location!.address ?? 
            '${locationState.location!.latitude}, ${locationState.location!.longitude}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationState = ref.watch(locationProvider);
    final searchState = ref.watch(therapistSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Búsqueda Avanzada'),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: _openMapSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationSection(theme, locationState),
                  SizedBox(height: 24),
                  _buildDistanceSection(theme),
                  SizedBox(height: 24),
                  _buildSpecialtiesSection(theme),
                  SizedBox(height: 24),
                  _buildRatingSection(theme),
                  SizedBox(height: 24),
                  _buildPriceSection(theme),
                  SizedBox(height: 24),
                  _buildLanguagesSection(theme),
                  SizedBox(height: 24),
                  _buildConsultationTypeSection(theme),
                  SizedBox(height: 24),
                  _buildAvailabilitySection(theme),
                  SizedBox(height: 24),
                  _buildSearchStats(theme),
                ],
              ),
            ),
          ),
          _buildSearchButton(theme, searchState),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme, LocationState locationState) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            // Ubicación actual
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Ubicación de búsqueda',
                      hintText: 'Ingresa dirección o usa ubicación actual',
                      prefixIcon: Icon(Icons.location_on),
                      suffixIcon: locationState.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: Icon(Icons.my_location),
                              onPressed: _getCurrentLocation,
                            ),
                    ),
                    onSubmitted: _searchLocationByAddress,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Búsqueda por ciudad
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'O buscar por ciudad',
                hintText: 'Ej: Ciudad de México, Guadalajara',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Toggle para solo online
            SwitchListTile(
              title: Text('Solo terapeutas online'),
              subtitle: Text('Buscar sin restricción geográfica'),
              value: _onlineOnly,
              onChanged: (value) {
                setState(() {
                  _onlineOnly = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distancia máxima',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('1 km'),
                Expanded(
                  child: Slider(
                    value: _maxDistance,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_maxDistance.toInt()} km',
                    onChanged: _onlineOnly ? null : (value) {
                      setState(() {
                        _maxDistance = value;
                      });
                    },
                  ),
                ),
                Text('50 km'),
              ],
            ),
            Center(
              child: Text(
                '${_maxDistance.toInt()} kilómetros',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Especialidades',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSpecialties.map((specialty) {
                final isSelected = _selectedSpecialties.contains(specialty);
                return FilterChip(
                  label: Text(specialty),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSpecialties.add(specialty);
                      } else {
                        _selectedSpecialties.remove(specialty);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calificación mínima',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text('0'),
                Expanded(
                  child: Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ),
                Text('5'),
              ],
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  Text(
                    ' ${_minRating.toStringAsFixed(1)} o superior',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rango de precios',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 300,
              divisions: 30,
              labels: RangeLabels(
                '\$${_priceRange.start.toInt()}',
                '\$${_priceRange.end.toInt()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$0'),
                Text(
                  '\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text('\$300'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Idiomas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableLanguages.map((language) {
                final isSelected = _selectedLanguages.contains(language);
                return FilterChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLanguages.add(language);
                      } else {
                        _selectedLanguages.remove(language);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationTypeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de consulta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text('Consultorio físico'),
              value: _hasPhysicalConsultory,
              onChanged: (value) {
                setState(() {
                  _hasPhysicalConsultory = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Visitas a domicilio'),
              value: _offersHomeVisits,
              onChanged: (value) {
                setState(() {
                  _offersHomeVisits = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponibilidad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availabilityOptions.map((option) {
                final isSelected = _availability == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _availability = selected ? option : '';
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchStats(ThemeData theme) {
    final stats = ref.watch(searchStatsProvider);
    
    if (stats['total'] == 0) {
      return SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultados de búsqueda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    label: 'Total',
                    value: '${stats['total']}',
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    label: 'Rating prom.',
                    value: '${(stats['averageRating'] as double).toStringAsFixed(1)}',
                    theme: theme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.attach_money,
                    label: 'Precio prom.',
                    value: '\$${(stats['averagePrice'] as double).toInt()}',
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.location_on,
                    label: 'Distancia prom.',
                    value: '${(stats['averageDistance'] as double).toStringAsFixed(1)} km',
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchButton(ThemeData theme, TherapistSearchState searchState) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear),
                  label: Text('Limpiar'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: searchState.isLoading ? null : _performSearch,
                  icon: searchState.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.search),
                  label: Text('Buscar Terapeutas'),
                ),
              ),
            ],
          ),
          if (searchState.error != null) ...[
            SizedBox(height: 8),
            Text(
              searchState.error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    await ref.read(locationProvider.notifier).getCurrentLocation();
    final locationState = ref.read(locationProvider);
    
    if (locationState.location != null) {
      _locationController.text = locationState.location!.address ?? 
          '${locationState.location!.latitude}, ${locationState.location!.longitude}';
    }
  }

  void _searchLocationByAddress(String address) async {
    if (address.isNotEmpty) {
      await ref.read(locationProvider.notifier).searchLocationByAddress(address);
    }
  }

  void _performSearch() async {
    final searchNotifier = ref.read(therapistSearchProvider.notifier);
    
    // Crear filtros
    final filters = TherapistSearchFilters(
      maxDistance: _onlineOnly ? null : _maxDistance,
      specialties: _selectedSpecialties.isEmpty ? null : _selectedSpecialties,
      minRating: _minRating == 0 ? null : _minRating,
      maxPrice: _priceRange.end == 300 ? null : _priceRange.end,
      languages: _selectedLanguages.isEmpty ? null : _selectedLanguages,
      hasPhysicalConsultory: _hasPhysicalConsultory ? true : null,
      offersHomeVisits: _offersHomeVisits ? true : null,
      availability: _availability.isEmpty ? null : _availability,
    );

    if (_onlineOnly) {
      // Búsqueda solo online
      await searchNotifier.searchOnlineTherapists(filters: filters);
    } else if (_cityController.text.isNotEmpty) {
      // Búsqueda por ciudad
      await searchNotifier.searchInCity(
        city: _cityController.text,
        filters: filters,
      );
    } else {
      // Búsqueda por ubicación
      final locationState = ref.read(locationProvider);
      if (locationState.location != null) {
        await searchNotifier.searchNearby(
          location: locationState.location!,
          radiusKm: _maxDistance,
          filters: filters,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, establece una ubicación para buscar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Navegar a resultados
    _showResults();
  }

  void _showResults() {
    Navigator.pop(context, true); // Retornar a la pantalla anterior con indicador de búsqueda realizada
  }

  void _openMapSearch() async {
    final locationState = ref.read(locationProvider);
    
    if (locationState.location != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TherapistMapScreen(
            initialLocation: locationState.location,
            initialRadius: _maxDistance,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Obteniendo ubicación para mostrar mapa...'),
        ),
      );
      
      _getCurrentLocation();
      final newLocationState = ref.read(locationProvider);
      
      if (newLocationState.location != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TherapistMapScreen(
              initialLocation: newLocationState.location,
              initialRadius: _maxDistance,
            ),
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _maxDistance = 10.0;
      _selectedSpecialties.clear();
      _minRating = 0.0;
      _priceRange = RangeValues(0, 300);
      _selectedLanguages.clear();
      _onlineOnly = false;
      _hasPhysicalConsultory = false;
      _offersHomeVisits = false;
      _availability = '';
      _cityController.clear();
    });
    
    ref.read(therapistSearchProvider.notifier).clearSearch();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}