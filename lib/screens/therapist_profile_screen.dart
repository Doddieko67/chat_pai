// lib/screens/therapist_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo extendido para el perfil del terapeuta
class TherapistProfile {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String imageUrl;
  final List<String> specialties;
  final List<String> languages;
  final double rating;
  final int reviewCount;
  final String experience;
  final double pricePerSession;
  final String availability;
  final bool isOnline;
  final bool isVerified;
  final List<String> certifications;
  final List<String> education;
  final List<String> approaches;
  final Map<String, String> schedule;
  final List<Review> reviews;
  final ContactInfo contactInfo;
  final ProfessionalInfo professionalInfo;

  TherapistProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    required this.imageUrl,
    required this.specialties,
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.pricePerSession,
    required this.availability,
    required this.isOnline,
    required this.isVerified,
    required this.certifications,
    required this.education,
    required this.approaches,
    required this.schedule,
    required this.reviews,
    required this.contactInfo,
    required this.professionalInfo,
  });
}

class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ContactInfo {
  final String email;
  final String phone;
  final String address;
  final String website;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
  });
}

class ProfessionalInfo {
  final String licenseNumber;
  final String institution;
  final int yearsOfExperience;
  final List<String> publications;

  ProfessionalInfo({
    required this.licenseNumber,
    required this.institution,
    required this.yearsOfExperience,
    required this.publications,
  });
}

class TherapistProfileScreen extends ConsumerStatefulWidget {
  final String therapistId;

  const TherapistProfileScreen({
    Key? key,
    required this.therapistId,
  }) : super(key: key);

  @override
  ConsumerState<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends ConsumerState<TherapistProfileScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool isBookmarked = false;
  bool isLoading = true;
  TherapistProfile? therapist;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    _loadTherapistProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil del Terapeuta')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (therapist == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil del Terapeuta')),
        body: Center(child: Text('Terapeuta no encontrado')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          _buildSliverAppBar(theme, colorScheme),
          
          // Contenido principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Información básica
                _buildBasicInfo(theme, colorScheme),
                
                // Tabs de navegación
                _buildTabBar(theme, colorScheme),
              ],
            ),
          ),
          
          // Contenido de los tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildOverviewTab(),
                _buildExperienceTab(),
                _buildScheduleTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme, colorScheme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 280,
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
              SizedBox(height: 60), // Espacio para el AppBar
              
              // Avatar con indicador de verificación
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.onPrimary,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surface,
                      backgroundImage: NetworkImage(therapist!.imageUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: therapist!.imageUrl.isEmpty
                          ? Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  if (therapist!.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  if (therapist!.isOnline)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 16),
              
              Text(
                therapist!.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              Text(
                therapist!.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              // Rating y disponibilidad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    '${therapist!.rating} (${therapist!.reviewCount} reseñas)',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: therapist!.isOnline ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      therapist!.isOnline ? 'En línea' : therapist!.availability,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            _showShareDialog();
          },
          icon: Icon(
            Icons.share,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.work,
              value: therapist!.experience,
              label: 'Experiencia',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.language,
              value: '${therapist!.languages.length}',
              label: 'Idiomas',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money,
              value: '\$${therapist!.pricePerSession.round()}',
              label: 'Por sesión',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
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
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
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

  Widget _buildTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Información'),
          Tab(text: 'Experiencia'),
          Tab(text: 'Horarios'),
          Tab(text: 'Reseñas'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biografía
          _buildSection(
            title: 'Acerca de',
            icon: Icons.person_outline,
            child: Text(
              therapist!.bio,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Especialidades
          _buildSection(
            title: 'Especialidades',
            icon: Icons.psychology,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: therapist!.specialties.map((specialty) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Enfoques terapéuticos
          _buildSection(
            title: 'Enfoques Terapéuticos',
            icon: Icons.healing,
            child: Column(
              children: therapist!.approaches.map((approach) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          approach,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Idiomas
          _buildSection(
            title: 'Idiomas',
            icon: Icons.language,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: therapist!.languages.map((language) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Educación
          _buildSection(
            title: 'Educación',
            icon: Icons.school,
            child: Column(
              children: therapist!.education.map((edu) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          edu,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Certificaciones
          _buildSection(
            title: 'Certificaciones',
            icon: Icons.card_membership,
            child: Column(
              children: therapist!.certifications.map((cert) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Información profesional
          _buildSection(
            title: 'Información Profesional',
            icon: Icons.badge,
            child: Container(
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
                  _buildInfoRow(
                    'Licencia',
                    therapist!.professionalInfo.licenseNumber,
                    Icons.badge,
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    'Institución',
                    therapist!.professionalInfo.institution,
                    Icons.business,
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    'Años de experiencia',
                    '${therapist!.professionalInfo.yearsOfExperience} años',
                    Icons.timeline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Horarios Disponibles',
            icon: Icons.schedule,
            child: Column(
              children: therapist!.schedule.entries.map((entry) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los horarios pueden variar según disponibilidad. Contacta para confirmar.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de reseñas
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      therapist!.rating.toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < therapist!.rating.floor()
                              ? Icons.star
                              : index < therapist!.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      '${therapist!.reviewCount} reseñas',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final starCount = 5 - index;
                      final percentage = (starCount <= therapist!.rating) ? 0.8 : 0.2;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$starCount'),
                            SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Lista de reseñas
          ...therapist!.reviews.map((review) {
            return Container(
              margin: EdgeInsets.only(bottom: 16),
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
                        radius: 20,
                        backgroundImage: review.userAvatar.isNotEmpty
                            ? NetworkImage(review.userAvatar)
                            : null,
                        child: review.userAvatar.isEmpty
                            ? Text(review.userName[0].toUpperCase())
                            : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14,
                                  );
                                }),
                                SizedBox(width: 8),
                                Text(
                                  _formatDate(review.date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    review.comment,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
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
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showContactDialog();
              },
              icon: Icon(Icons.message),
              label: Text('Mensaje'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showBookingDialog();
              },
              icon: Icon(Icons.calendar_today),
              label: Text('Reservar Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Future<void> _loadTherapistProfile() async {
    // Simular carga de datos
    await Future.delayed(Duration(seconds: 1));

    // Datos de ejemplo
    therapist = TherapistProfile(
      id: widget.therapistId,
      name: 'Dra. María González',
      title: 'Psicóloga Clínica Especializada',
      bio: 'Soy una psicóloga clínica con más de 8 años de experiencia ayudando a personas a superar desafíos emocionales y mejorar su bienestar mental. Mi enfoque se centra en crear un espacio seguro y de apoyo donde mis pacientes puedan explorar sus sentimientos y desarrollar herramientas efectivas para el manejo del estrés, la ansiedad y la depresión.',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
      specialties: ['Ansiedad', 'Depresión', 'Trauma', 'Estrés', 'Autoestima'],
      languages: ['Español', 'Inglés', 'Francés'],
      rating: 4.8,
      reviewCount: 124,
      experience: '8 años',
      pricePerSession: 80,
      availability: 'Disponible hoy',
      isOnline: true,
      isVerified: true,
      certifications: [
        'Certificación en Terapia Cognitivo-Conductual',
        'Especialización en Trauma y PTSD',
        'Certificación en Mindfulness y Meditación',
      ],
      education: [
        'Doctorado en Psicología Clínica - Universidad Nacional',
        'Maestría en Psicoterapia - Instituto Superior de Psicología',
        'Licenciatura en Psicología - Universidad de Buenos Aires',
      ],
      approaches: [
        'Terapia Cognitivo-Conductual (TCC)',
        'Terapia de Aceptación y Compromiso (ACT)',
        'Mindfulness y Técnicas de Relajación',
        'Terapia Humanista',
      ],
      schedule: {
        'Lunes': '9:00 AM - 6:00 PM',
        'Martes': '9:00 AM - 6:00 PM',
        'Miércoles': '10:00 AM - 4:00 PM',
        'Jueves': '9:00 AM - 6:00 PM',
        'Viernes': '9:00 AM - 5:00 PM',
        'Sábado': '10:00 AM - 2:00 PM',
        'Domingo': 'No disponible',
      },
      reviews: [
        Review(
          id: '1',
          userName: 'Ana García',
          userAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b6f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          rating: 5.0,
          comment: 'Excelente profesional. Me ayudó muchísimo con mi ansiedad y ahora me siento mucho mejor. Muy recomendada.',
          date: DateTime.now().subtract(Duration(days: 5)),
        ),
        Review(
          id: '2',
          userName: 'Carlos Ruiz',
          userAvatar: '',
          rating: 4.5,
          comment: 'Muy buena terapeuta, paciente y comprensiva. Las sesiones son muy productivas.',
          date: DateTime.now().subtract(Duration(days: 12)),
        ),
        Review(
          id: '3',
          userName: 'Laura Martínez',
          userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          rating: 5.0,
          comment: 'Increíble experiencia. La Dra. González es muy profesional y empática. Me ayudó a superar un momento muy difícil.',
          date: DateTime.now().subtract(Duration(days: 20)),
        ),
      ],
      contactInfo: ContactInfo(
        email: 'maria.gonzalez@email.com',
        phone: '+1 234 567 8900',
        address: 'Av. Principal 123, Ciudad',
        website: 'www.mariagonzalez.com',
      ),
      professionalInfo: ProfessionalInfo(
        licenseNumber: 'PSI-2024-001234',
        institution: 'Colegio de Psicólogos Nacional',
        yearsOfExperience: 8,
        publications: [
          'Manejo de la Ansiedad en Tiempos Modernos',
          'Técnicas de Mindfulness para el Bienestar',
        ],
      ),
    );

    setState(() {
      isLoading = false;
    });
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Compartir Perfil'),
        content: Text('¿Cómo te gustaría compartir este perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Perfil compartido')),
              );
            },
            child: Text('Compartir'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contactar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
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
              subtitle: Text(therapist!.contactInfo.phone),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar llamada
              },
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Enviar email'),
              subtitle: Text(therapist!.contactInfo.email),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar email
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reservar Cita'),
        content: Text('¿Te gustaría reservar una cita con ${therapist!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar sistema de reservas
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Redirigiendo a reservas...')),
              );
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}