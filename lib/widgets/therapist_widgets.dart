// lib/widgets/therapist_widgets.dart
import 'package:flutter/material.dart';

// Modelo de datos para Terapeuta
class Therapist {
  final String id;
  final String name;
  final String title;
  final String specialties;
  final List<String> languages;
  final double rating;
  final int reviewCount;
  final String experience;
  final double pricePerSession;
  final String availability;
  final bool isOnline;
  final bool isVerified;
  final String imageUrl;
  final String description;
  final List<String> specialtyTags;

  Therapist({
    required this.id,
    required this.name,
    required this.title,
    required this.specialties,
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.pricePerSession,
    required this.availability,
    required this.isOnline,
    required this.isVerified,
    required this.imageUrl,
    required this.description,
    required this.specialtyTags,
  });
}

// Widget 1: Tarjeta de Terapeuta
class TherapistCard extends StatelessWidget {
  final Therapist therapist;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onContact;
  final bool isBookmarked;

  const TherapistCard({
    Key? key,
    required this.therapist,
    this.onTap,
    this.onBookmark,
    this.onContact,
    this.isBookmarked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con foto, info básica y bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto del terapeuta
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        backgroundImage: NetworkImage(therapist.imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: therapist.imageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 32,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      // Indicador de estado online
                      if (therapist.isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Información básica
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                therapist.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (therapist.isVerified)
                              Container(
                                margin: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        
                        SizedBox(height: 2),
                        
                        Text(
                          therapist.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        SizedBox(height: 4),
                        
                        Text(
                          therapist.specialties,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón bookmark
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Tags de especialidades
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: therapist.specialtyTags.take(3).map((tag) {
                  return SpecialtyChip(
                    label: tag,
                    size: SpecialtyChipSize.small,
                  );
                }).toList(),
              ),
              
              SizedBox(height: 12),
              
              // Rating, experiencia y disponibilidad
              Row(
                children: [
                  StarRating(
                    rating: therapist.rating,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${therapist.rating}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(${therapist.reviewCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  
                  Spacer(),
                  
                  Icon(
                    Icons.work_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    therapist.experience,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Row(
                children: [
                  AvailabilityIndicator(
                    availability: therapist.availability,
                    isOnline: therapist.isOnline,
                  ),
                  
                  Spacer(),
                  
                  Text(
                    '\$${therapist.pricePerSession.toStringAsFixed(0)}/sesión',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ContactButton(
                      onPressed: onContact,
                      type: ContactButtonType.message,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ContactButton(
                      onPressed: () {},
                      type: ContactButtonType.book,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget 2: Chip de Especialidad
enum SpecialtyChipSize { small, medium, large }

class SpecialtyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final SpecialtyChipSize size;

  const SpecialtyChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.size = SpecialtyChipSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    double horizontalPadding;
    double verticalPadding;
    double fontSize;
    
    switch (size) {
      case SpecialtyChipSize.small:
        horizontalPadding = 8;
        verticalPadding = 4;
        fontSize = 12;
        break;
      case SpecialtyChipSize.medium:
        horizontalPadding = 12;
        verticalPadding = 6;
        fontSize = 13;
        break;
      case SpecialtyChipSize.large:
        horizontalPadding = 16;
        verticalPadding = 8;
        fontSize = 14;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.primary,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Widget 3: Indicador de Disponibilidad
class AvailabilityIndicator extends StatelessWidget {
  final String availability;
  final bool isOnline;

  const AvailabilityIndicator({
    Key? key,
    required this.availability,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isOnline) {
      statusColor = Colors.green;
      statusText = 'En línea';
      statusIcon = Icons.circle;
    } else if (availability.toLowerCase().contains('disponible')) {
      statusColor = Colors.orange;
      statusText = availability;
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.grey;
      statusText = availability;
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget 4: Rating con Estrellas
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final int maxStars;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color,
    this.maxStars = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        if (index < rating.floor()) {
          // Estrella completa
          return Icon(
            Icons.star,
            size: size,
            color: starColor,
          );
        } else if (index < rating) {
          // Media estrella
          return Icon(
            Icons.star_half,
            size: size,
            color: starColor,
          );
        } else {
          // Estrella vacía
          return Icon(
            Icons.star_border,
            size: size,
            color: starColor.withOpacity(0.3),
          );
        }
      }),
    );
  }
}

// Widget 5: Botón de Contacto
enum ContactButtonType { message, book, call, video }

class ContactButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ContactButtonType type;
  final bool isLoading;

  const ContactButton({
    Key? key,
    this.onPressed,
    required this.type,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String text;
    IconData icon;
    bool isPrimary;

    switch (type) {
      case ContactButtonType.message:
        text = 'Mensaje';
        icon = Icons.message;
        isPrimary = false;
        break;
      case ContactButtonType.book:
        text = 'Reservar';
        icon = Icons.calendar_today;
        isPrimary = true;
        break;
      case ContactButtonType.call:
        text = 'Llamar';
        icon = Icons.phone;
        isPrimary = false;
        break;
      case ContactButtonType.video:
        text = 'Video';
        icon = Icons.videocam;
        isPrimary = true;
        break;
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPrimary ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ),
            )
          : Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? colorScheme.primary
            : colorScheme.surface,
        foregroundColor: isPrimary
            ? colorScheme.onPrimary
            : colorScheme.primary,
        side: isPrimary
            ? null
            : BorderSide(color: colorScheme.primary),
        padding: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isPrimary ? 2 : 0,
      ),
    );
  }
}

// Widget 6: Filtros de Búsqueda
class TherapistFilters extends StatelessWidget {
  final List<String> selectedSpecialties;
  final String selectedAvailability;
  final RangeValues priceRange;
  final double minRating;
  final List<String> selectedLanguages;
  final Function(List<String>) onSpecialtiesChanged;
  final Function(String) onAvailabilityChanged;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(double) onMinRatingChanged;
  final Function(List<String>) onLanguagesChanged;
  final VoidCallback onClearFilters;

  const TherapistFilters({
    Key? key,
    required this.selectedSpecialties,
    required this.selectedAvailability,
    required this.priceRange,
    required this.minRating,
    required this.selectedLanguages,
    required this.onSpecialtiesChanged,
    required this.onAvailabilityChanged,
    required this.onPriceRangeChanged,
    required this.onMinRatingChanged,
    required this.onLanguagesChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final specialties = [
      'Ansiedad',
      'Depresión',
      'Terapia de Pareja',
      'Trauma',
      'Estrés',
      'Autoestima',
      'Familia',
      'Adicciones',
    ];

    final languages = ['Español', 'Inglés', 'Francés', 'Portugués'];
    final availabilities = ['Disponible ahora', 'Hoy', 'Esta semana', 'Próximos días'];

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filtros',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: onClearFilters,
                child: Text('Limpiar'),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Especialidades
          Text(
            'Especialidades',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: specialties.map((specialty) {
              final isSelected = selectedSpecialties.contains(specialty);
              return SpecialtyChip(
                label: specialty,
                isSelected: isSelected,
                onTap: () {
                  final newSelection = List<String>.from(selectedSpecialties);
                  if (isSelected) {
                    newSelection.remove(specialty);
                  } else {
                    newSelection.add(specialty);
                  }
                  onSpecialtiesChanged(newSelection);
                },
              );
            }).toList(),
          ),
          
          SizedBox(height: 24),
          
          // Disponibilidad
          Text(
            'Disponibilidad',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: availabilities.map((availability) {
              final isSelected = selectedAvailability == availability;
              return SpecialtyChip(
                label: availability,
                isSelected: isSelected,
                onTap: () => onAvailabilityChanged(
                  isSelected ? '' : availability,
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 24),
          
          // Rango de precios
          Text(
            'Precio por sesión: \$${priceRange.start.round()} - \$${priceRange.end.round()}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          RangeSlider(
            values: priceRange,
            min: 50,
            max: 200,
            divisions: 15,
            onChanged: onPriceRangeChanged,
            activeColor: colorScheme.primary,
          ),
          
          SizedBox(height: 24),
          
          // Rating mínimo
          Text(
            'Rating mínimo: ${minRating.toStringAsFixed(1)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: minRating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  onChanged: onMinRatingChanged,
                  activeColor: colorScheme.primary,
                ),
              ),
              SizedBox(width: 8),
              StarRating(
                rating: minRating,
                size: 16,
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Idiomas
          Text(
            'Idiomas',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: languages.map((language) {
              final isSelected = selectedLanguages.contains(language);
              return SpecialtyChip(
                label: language,
                isSelected: isSelected,
                onTap: () {
                  final newSelection = List<String>.from(selectedLanguages);
                  if (isSelected) {
                    newSelection.remove(language);
                  } else {
                    newSelection.add(language);
                  }
                  onLanguagesChanged(newSelection);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Widget 7: Skeleton Loader
class TherapistCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar skeleton
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre skeleton
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Título skeleton
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Especialidad skeleton
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Tags skeleton
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                width: 60 + (index * 10),
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          // Botones skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget 8: Estado Vacío
class EmptyTherapistState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final String? actionText;

  const EmptyTherapistState({
    Key? key,
    this.title = 'No se encontraron terapeutas',
    this.subtitle = 'Intenta ajustar tus filtros de búsqueda',
    this.onRetry,
    this.actionText = 'Reintentar',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}