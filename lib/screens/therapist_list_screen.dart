// lib/screens/therapist_list_screen.dart
import 'package:chat_pai/screens/therapist_profile_screen.dart';
import 'package:chat_pai/widgets/therapist_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_pai/widgets/therapist_widgets.dart';

class TherapistListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TherapistListScreen> createState() => _TherapistListScreenState();
}

class _TherapistListScreenState extends ConsumerState<TherapistListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> selectedSpecialties = [];
  String selectedAvailability = '';
  RangeValues priceRange = RangeValues(50, 150);
  double minRating = 3.0;
  List<String> selectedLanguages = [];
  Set<String> bookmarkedIds = {};
  bool isLoading = false;
  List<Therapist> therapists = [];
  List<Therapist> filteredTherapists = [];

  @override
  void initState() {
    super.initState();
    _loadTherapists();
    searchController.addListener(_filterTherapists);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Terapeutas Disponibles'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFiltersBottomSheet,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar terapeutas...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Chips de filtros activos
          if (_hasActiveFilters()) _buildActiveFiltersChips(),

          // Lista de terapeutas
          Expanded(
            child: _buildTherapistsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapistSearchScreen(),
            ),
          );
        },
        icon: Icon(Icons.search),
        label: Text('Búsqueda Avanzada'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (selectedSpecialties.isNotEmpty)
            ...selectedSpecialties.map((specialty) {
              return Container(
                margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Chip(
                  label: Text(specialty),
                  onDeleted: () {
                    setState(() {
                      selectedSpecialties.remove(specialty);
                    });
                    _filterTherapists();
                  },
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  deleteIconColor: colorScheme.primary,
                ),
              );
            }).toList(),
          
          if (selectedAvailability.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: Chip(
                label: Text(selectedAvailability),
                onDeleted: () {
                  setState(() {
                    selectedAvailability = '';
                  });
                  _filterTherapists();
                },
                backgroundColor: colorScheme.secondary.withOpacity(0.1),
                deleteIconColor: colorScheme.secondary,
              ),
            ),
          
          if (selectedLanguages.isNotEmpty)
            ...selectedLanguages.map((language) {
              return Container(
                margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Chip(
                  label: Text(language),
                  onDeleted: () {
                    setState(() {
                      selectedLanguages.remove(language);
                    });
                    _filterTherapists();
                  },
                  backgroundColor: Colors.green.withOpacity(0.1),
                  deleteIconColor: Colors.green,
                ),
              );
            }).toList(),
          
          // Botón limpiar todo
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ActionChip(
              label: Text('Limpiar todo'),
              onPressed: _clearAllFilters,
              backgroundColor: Colors.red.withOpacity(0.1),
              side: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistsList() {
    if (isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => TherapistCardSkeleton(),
      );
    }

    if (filteredTherapists.isEmpty) {
      return EmptyTherapistState(
        title: searchController.text.isNotEmpty 
          ? 'No se encontraron resultados'
          : 'No hay terapeutas disponibles',
        subtitle: searchController.text.isNotEmpty
          ? 'Intenta con otros términos de búsqueda'
          : 'Intenta ajustar tus filtros',
        onRetry: _loadTherapists,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadTherapists();
      },
      child: ListView.builder(
        itemCount: filteredTherapists.length,
        itemBuilder: (context, index) {
          final therapist = filteredTherapists[index];
          return TherapistCard(
            therapist: therapist,
            isBookmarked: bookmarkedIds.contains(therapist.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TherapistProfileScreen(
                    therapistId: therapist.id,
                  ),
                ),
              );
            },
            onBookmark: () {
              setState(() {
                if (bookmarkedIds.contains(therapist.id)) {
                  bookmarkedIds.remove(therapist.id);
                } else {
                  bookmarkedIds.add(therapist.id);
                }
              });
            },
            onContact: () {
              _showContactOptions(context, therapist);
            },
          );
        },
      ),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: TherapistFilters(
            selectedSpecialties: selectedSpecialties,
            selectedAvailability: selectedAvailability,
            priceRange: priceRange,
            minRating: minRating,
            selectedLanguages: selectedLanguages,
            onSpecialtiesChanged: (specialties) {
              setState(() {
                selectedSpecialties = specialties;
              });
              _filterTherapists();
            },
            onAvailabilityChanged: (availability) {
              setState(() {
                selectedAvailability = availability;
              });
              _filterTherapists();
            },
            onPriceRangeChanged: (range) {
              setState(() {
                priceRange = range;
              });
              _filterTherapists();
            },
            onMinRatingChanged: (rating) {
              setState(() {
                minRating = rating;
              });
              _filterTherapists();
            },
            onLanguagesChanged: (languages) {
              setState(() {
                selectedLanguages = languages;
              });
              _filterTherapists();
            },
            onClearFilters: () {
              _clearAllFilters();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ordenar por',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Mejor puntuación'),
              onTap: () {
                _sortTherapists('rating');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Precio: menor a mayor'),
              onTap: () {
                _sortTherapists('price_asc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.money_off),
              title: Text('Precio: mayor a menor'),
              onTap: () {
                _sortTherapists('price_desc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Más experiencia'),
              onTap: () {
                _sortTherapists('experience');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.online_prediction),
              title: Text('Disponibles ahora'),
              onTap: () {
                _sortTherapists('online');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, Therapist therapist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(therapist.imageUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: therapist.imageUrl.isEmpty
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(therapist.name),
              subtitle: Text(therapist.title),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Enviar mensaje'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar chat
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Llamar'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar llamada
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Videollamada'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar videollamada
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Reservar cita'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(therapist: therapist),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTherapists() async {
    setState(() {
      isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(Duration(seconds: 1));

    // Datos de ejemplo
    therapists = [
      Therapist(
        id: '1',
        name: 'Dra. María González',
        title: 'Psicóloga Clínica',
        specialties: 'Ansiedad, Depresión, Terapia Cognitiva',
        languages: ['Español', 'Inglés'],
        rating: 4.8,
        reviewCount: 124,
        experience: '8 años',
        pricePerSession: 80,
        availability: 'Disponible hoy',
        isOnline: true,
        isVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        description: 'Especialista en trastornos de ansiedad y depresión con enfoque cognitivo-conductual.',
        specialtyTags: ['Ansiedad', 'Depresión', 'Trauma'],
      ),
      Therapist(
        id: '2',
        name: 'Dr. Carlos Ruiz',
        title: 'Terapeuta de Pareja',
        specialties: 'Terapia de Pareja, Terapia Familiar',
        languages: ['Español'],
        rating: 4.6,
        reviewCount: 89,
        experience: '12 años',
        pricePerSession: 120,
        availability: 'Esta semana',
        isOnline: false,
        isVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        description: 'Experto en terapia de pareja y familiar con más de una década de experiencia.',
        specialtyTags: ['Terapia de Pareja', 'Familia', 'Comunicación'],
      ),
      Therapist(
        id: '3',
        name: 'Lic. Ana Martínez',
        title: 'Psicóloga Infantil',
        specialties: 'Psicología Infantil, TDAH, Autismo',
        languages: ['Español', 'Inglés', 'Francés'],
        rating: 4.9,
        reviewCount: 156,
        experience: '6 años',
        pricePerSession: 90,
        availability: 'Disponible ahora',
        isOnline: true,
        isVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1594824575448-8392e0a04efe?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        description: 'Especializada en el desarrollo infantil y trastornos del neurodesarrollo.',
        specialtyTags: ['Niños', 'TDAH', 'Autismo'],
      ),
      Therapist(
        id: '4',
        name: 'Dr. Roberto Silva',
        title: 'Psiquiatra',
        specialties: 'Psiquiatría, Trastornos del Ánimo',
        languages: ['Español', 'Portugués'],
        rating: 4.7,
        reviewCount: 203,
        experience: '15 años',
        pricePerSession: 150,
        availability: 'Próximos días',
        isOnline: false,
        isVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        description: 'Psiquiatra con amplia experiencia en trastornos del estado de ánimo.',
        specialtyTags: ['Psiquiatría', 'Depresión', 'Bipolaridad'],
      ),
    ];

    setState(() {
      isLoading = false;
    });
    
    _filterTherapists();
  }

  void _filterTherapists() {
    filteredTherapists = therapists.where((therapist) {
      // Filtro por búsqueda de texto
      if (searchController.text.isNotEmpty) {
        final searchText = searchController.text.toLowerCase();
        if (!therapist.name.toLowerCase().contains(searchText) &&
            !therapist.specialties.toLowerCase().contains(searchText) &&
            !therapist.title.toLowerCase().contains(searchText)) {
          return false;
        }
      }

      // Filtro por especialidades
      if (selectedSpecialties.isNotEmpty) {
        bool hasSpecialty = false;
        for (String specialty in selectedSpecialties) {
          if (therapist.specialtyTags.contains(specialty)) {
            hasSpecialty = true;
            break;
          }
        }
        if (!hasSpecialty) return false;
      }

      // Filtro por disponibilidad
      if (selectedAvailability.isNotEmpty) {
        if (!therapist.availability.contains(selectedAvailability)) {
          return false;
        }
      }

      // Filtro por precio
      if (therapist.pricePerSession < priceRange.start || 
          therapist.pricePerSession > priceRange.end) {
        return false;
      }

      // Filtro por rating
      if (therapist.rating < minRating) {
        return false;
      }

      // Filtro por idiomas
      if (selectedLanguages.isNotEmpty) {
        bool hasLanguage = false;
        for (String language in selectedLanguages) {
          if (therapist.languages.contains(language)) {
            hasLanguage = true;
            break;
          }
        }
        if (!hasLanguage) return false;
      }

      return true;
    }).toList();

    setState(() {});
  }

  void _sortTherapists(String sortBy) {
    switch (sortBy) {
      case 'rating':
        filteredTherapists.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_asc':
        filteredTherapists.sort((a, b) => a.pricePerSession.compareTo(b.pricePerSession));
        break;
      case 'price_desc':
        filteredTherapists.sort((a, b) => b.pricePerSession.compareTo(a.pricePerSession));
        break;
      case 'experience':
        filteredTherapists.sort((a, b) {
          int expA = int.tryParse(a.experience.split(' ')[0]) ?? 0;
          int expB = int.tryParse(b.experience.split(' ')[0]) ?? 0;
          return expB.compareTo(expA);
        });
        break;
      case 'online':
        filteredTherapists.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return 0;
        });
        break;
    }
    setState(() {});
  }

  bool _hasActiveFilters() {
    return selectedSpecialties.isNotEmpty ||
           selectedAvailability.isNotEmpty ||
           selectedLanguages.isNotEmpty ||
           priceRange.start > 50 ||
           priceRange.end < 200 ||
           minRating > 3.0;
  }

  void _clearAllFilters() {
    setState(() {
      selectedSpecialties.clear();
      selectedAvailability = '';
      selectedLanguages.clear();
      priceRange = RangeValues(50, 200);
      minRating = 3.0;
    });
    _filterTherapists();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// lib/screens/therapist_detail_screen.dart
class TherapistDetailScreen extends StatefulWidget {
  final Therapist therapist;

  const TherapistDetailScreen({
    Key? key,
    required this.therapist,
  }) : super(key: key);

  @override
  State<TherapistDetailScreen> createState() => _TherapistDetailScreenState();
}

class _TherapistDetailScreenState extends State<TherapistDetailScreen> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.8),
                      colorScheme.primary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surface,
                      backgroundImage: NetworkImage(widget.therapist.imageUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: widget.therapist.imageUrl.isEmpty
                          ? Icon(Icons.person, size: 60)
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.therapist.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.therapist.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isBookmarked = !isBookmarked;
                  });
                },
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: colorScheme.onPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Compartir perfil
                },
                icon: Icon(
                  Icons.share,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          // Contenido del perfil
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats rápidos
                  _buildQuickStats(theme, colorScheme),
                  
                  SizedBox(height: 24),
                  
                  // Especialidades
                  _buildSpecialtiesSection(theme),
                  
                  SizedBox(height: 24),
                  
                  // Descripción
                  _buildDescriptionSection(theme),
                  
                  SizedBox(height: 24),
                  
                  // Disponibilidad y precios
                  _buildAvailabilitySection(theme, colorScheme),
                  
                  SizedBox(height: 24),
                  
                  // Idiomas
                  _buildLanguagesSection(theme, colorScheme),
                  
                  SizedBox(height: 24),
                  
                  // Reseñas
                  _buildReviewsSection(theme, colorScheme),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme, colorScheme),
    );
  }

  Widget _buildQuickStats(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: widget.therapist.rating.toString(),
            label: 'Rating',
            color: Colors.amber,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.reviews,
            value: widget.therapist.reviewCount.toString(),
            label: 'Reseñas',
            color: colorScheme.primary,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.work,
            value: widget.therapist.experience.split(' ')[0],
            label: 'Años exp.',
            color: Colors.green,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesSection(ThemeData theme) {
    return Column(
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
          children: widget.therapist.specialtyTags.map((tag) {
            return SpecialtyChip(
              label: tag,
              isSelected: true,
              size: SpecialtyChipSize.medium,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acerca de',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          widget.therapist.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponibilidad y Precios',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              AvailabilityIndicator(
                availability: widget.therapist.availability,
                isOnline: widget.therapist.isOnline,
              ),
              Spacer(),
              Text(
                '\$${widget.therapist.pricePerSession.toStringAsFixed(0)} por sesión',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
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
          children: widget.therapist.languages.map((language) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Text(
                language,
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reseñas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Ver todas las reseñas
              },
              child: Text('Ver todas'),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Aquí podrías agregar algunas reseñas de ejemplo
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text('A'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ana García',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  StarRating(rating: 5.0, size: 14),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Excelente profesional, me ayudó mucho con mi ansiedad. Muy recomendada.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ContactButton(
              onPressed: () {
                // TODO: Enviar mensaje
              },
              type: ContactButtonType.message,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ContactButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      therapist: widget.therapist,
                    ),
                  ),
                );
              },
              type: ContactButtonType.book,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/screens/therapist_search_screen.dart
class TherapistSearchScreen extends StatefulWidget {
  @override
  State<TherapistSearchScreen> createState() => _TherapistSearchScreenState();
}

class _TherapistSearchScreenState extends State<TherapistSearchScreen> {
  // Implementación de búsqueda avanzada...
  // (Similar a la anterior pero con más opciones de filtrado)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Búsqueda Avanzada'),
      ),
      body: Center(
        child: Text('Pantalla de búsqueda avanzada'),
      ),
    );
  }
}

// lib/screens/booking_screen.dart
class BookingScreen extends StatefulWidget {
  final Therapist therapist;

  const BookingScreen({
    Key? key,
    required this.therapist,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Cita'),
      ),
      body: Center(
        child: Text('Pantalla de reserva con ${widget.therapist.name}'),
      ),
    );
  }
}