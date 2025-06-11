// lib/screens/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_pai/riverpod/theme_provider.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool autoBackup = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Perfil
            _buildProfileSection(theme, colorScheme),
            
            SizedBox(height: 32),
            
            // Sección de Configuración General
            _buildSectionTitle('Configuración General', theme),
            SizedBox(height: 16),
            _buildThemeOption(theme, colorScheme, themeMode),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Idioma',
              subtitle: 'Español',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageSelector(context),
              theme: theme,
            ),
            _buildSettingsTile(
              icon: Icons.font_download,
              title: 'Tamaño de fuente',
              subtitle: 'Mediano',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFontSizeSelector(context),
              theme: theme,
            ),
            
            SizedBox(height: 32),
            
            // Sección de Notificaciones
            _buildSectionTitle('Notificaciones', theme),
            SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Notificaciones push',
              subtitle: 'Recibir notificaciones de mensajes',
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.volume_up,
              title: 'Sonido',
              subtitle: 'Sonido de notificaciones',
              value: soundEnabled,
              onChanged: (value) {
                setState(() {
                  soundEnabled = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.vibration,
              title: 'Vibración',
              subtitle: 'Vibrar al recibir mensajes',
              value: vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  vibrationEnabled = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            
            SizedBox(height: 32),
            
            // Sección de Privacidad y Seguridad
            _buildSectionTitle('Privacidad y Seguridad', theme),
            SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.lock,
              title: 'Cambiar contraseña',
              subtitle: 'Actualizar tu contraseña',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
              theme: theme,
            ),
            _buildSwitchTile(
              icon: Icons.backup,
              title: 'Copia de seguridad automática',
              subtitle: 'Respaldar chats en la nube',
              value: autoBackup,
              onChanged: (value) {
                setState(() {
                  autoBackup = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSettingsTile(
              icon: Icons.shield,
              title: 'Privacidad',
              subtitle: 'Control de datos y privacidad',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyOptions(context),
              theme: theme,
            ),
            
            SizedBox(height: 32),
            
            // Sección de Soporte
            _buildSectionTitle('Soporte', theme),
            SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              subtitle: 'Preguntas frecuentes y soporte',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
              theme: theme,
            ),
            _buildSettingsTile(
              icon: Icons.feedback,
              title: 'Enviar comentarios',
              subtitle: 'Comparte tu experiencia',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFeedbackDialog(context),
              theme: theme,
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Acerca de',
              subtitle: 'Versión 1.0.0',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAboutDialog(context),
              theme: theme,
            ),
            
            SizedBox(height: 32),
            
            // Botón Cerrar Sesión
            _buildLogoutButton(theme, colorScheme),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20),
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
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                  ),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juan Pérez',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'juan.perez@email.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Premium',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Botón editar
          IconButton(
            onPressed: () => _showEditProfileDialog(context),
            icon: Icon(Icons.edit),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              foregroundColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildThemeOption(ThemeData theme, ColorScheme colorScheme, ThemeModeType themeMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            themeMode == ThemeModeType.light 
              ? Icons.light_mode 
              : Icons.dark_mode,
            color: colorScheme.primary,
          ),
        ),
        title: Text('Tema'),
        subtitle: Text(
          themeMode == ThemeModeType.light ? 'Modo claro' : 'Modo oscuro'
        ),
        trailing: Switch(
          value: themeMode == ThemeModeType.dark,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).state = 
              value ? ThemeModeType.dark : ThemeModeType.light;
          },
          activeColor: colorScheme.primary,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: Icon(Icons.logout),
        label: Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Métodos para mostrar diálogos y opciones
  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
              initialValue: 'Juan Pérez',
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              initialValue: 'juan.perez@email.com',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Idioma',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Español'),
              trailing: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Français'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tamaño de Fuente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Pequeño'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Mediano'),
              trailing: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Grande'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Privacidad')),
          body: Center(child: Text('Opciones de privacidad')),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enviar Comentarios'),
        content: TextFormField(
          decoration: InputDecoration(
            hintText: 'Escribe tus comentarios aquí...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Chat Interactivo',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.chat_bubble_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 48,
      ),
      children: [
        Text('Una aplicación de chat moderna y fácil de usar.'),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartir app'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.star_rate),
              title: Text('Calificar app'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('Reportar problema'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}