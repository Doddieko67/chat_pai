// lib/screens/chat_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends ConsumerState<ChatSettingsScreen> {
  // Configuraciones de Apariencia
  double fontSize = 16.0;
  String bubbleStyle = 'rounded';
  String wallpaper = 'default';
  bool showTimestamps = true;
  bool show24HourFormat = false;
  
  // Configuraciones de Comportamiento
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool readReceipts = true;
  bool typingIndicators = true;
  bool autoScroll = true;
  double messageSpeed = 1.0;
  
  // Configuraciones de Privacidad
  bool autoDeleteMessages = false;
  int deleteAfterDays = 30;
  bool encryptMessages = true;
  bool saveHistory = true;
  
  // Configuraciones del Asistente
  String aiPersonality = 'friendly';
  String responseLength = 'balanced';
  bool smartSuggestions = true;
  bool contextAwareness = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración del Chat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Restaurar valores por defecto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Apariencia
            _buildSectionTitle('Apariencia del Chat', theme, Icons.palette),
            SizedBox(height: 16),
            _buildFontSizeSlider(theme, colorScheme),
            _buildBubbleStyleSelector(theme, colorScheme),
            _buildWallpaperSelector(theme, colorScheme),
            _buildSwitchTile(
              icon: Icons.access_time,
              title: 'Mostrar hora de mensajes',
              subtitle: 'Ver timestamp en cada mensaje',
              value: showTimestamps,
              onChanged: (value) {
                setState(() {
                  showTimestamps = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.schedule,
              title: 'Formato 24 horas',
              subtitle: 'Usar formato de 24 horas para la hora',
              value: show24HourFormat,
              onChanged: (value) {
                setState(() {
                  show24HourFormat = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            
            SizedBox(height: 32),
            
            // Sección de Comportamiento
            _buildSectionTitle('Comportamiento', theme, Icons.tune),
            SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.volume_up,
              title: 'Sonidos de mensaje',
              subtitle: 'Reproducir sonido al enviar/recibir',
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
            _buildSwitchTile(
              icon: Icons.done_all,
              title: 'Confirmaciones de lectura',
              subtitle: 'Mostrar cuando los mensajes son leídos',
              value: readReceipts,
              onChanged: (value) {
                setState(() {
                  readReceipts = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.edit,
              title: 'Indicador de escritura',
              subtitle: 'Mostrar cuando el asistente está escribiendo',
              value: typingIndicators,
              onChanged: (value) {
                setState(() {
                  typingIndicators = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.vertical_align_bottom,
              title: 'Auto-scroll',
              subtitle: 'Desplazarse automáticamente a nuevos mensajes',
              value: autoScroll,
              onChanged: (value) {
                setState(() {
                  autoScroll = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildMessageSpeedSlider(theme, colorScheme),
            
            SizedBox(height: 32),
            
            // Sección de Privacidad
            _buildSectionTitle('Privacidad y Datos', theme, Icons.security),
            SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.auto_delete,
              title: 'Eliminación automática',
              subtitle: autoDeleteMessages 
                ? 'Eliminar mensajes después de $deleteAfterDays días'
                : 'Los mensajes se guardan indefinidamente',
              value: autoDeleteMessages,
              onChanged: (value) {
                setState(() {
                  autoDeleteMessages = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            if (autoDeleteMessages) _buildDeleteDaysSelector(theme, colorScheme),
            _buildSwitchTile(
              icon: Icons.enhanced_encryption,
              title: 'Encriptación de mensajes',
              subtitle: 'Proteger mensajes con encriptación local',
              value: encryptMessages,
              onChanged: (value) {
                setState(() {
                  encryptMessages = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.history,
              title: 'Guardar historial',
              subtitle: 'Mantener historial de conversaciones',
              value: saveHistory,
              onChanged: (value) {
                setState(() {
                  saveHistory = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSettingsTile(
              icon: Icons.download,
              title: 'Exportar conversaciones',
              subtitle: 'Descargar historial como archivo',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showExportDialog(context),
              theme: theme,
            ),
            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: 'Borrar todo el historial',
              subtitle: 'Eliminar todas las conversaciones',
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClearHistoryDialog(context),
              theme: theme,
            ),
            
            SizedBox(height: 32),
            
            // Sección del Asistente IA
            _buildSectionTitle('Configuración del Asistente', theme, Icons.smart_toy),
            SizedBox(height: 16),
            _buildPersonalitySelector(theme, colorScheme),
            _buildResponseLengthSelector(theme, colorScheme),
            _buildSwitchTile(
              icon: Icons.lightbulb,
              title: 'Sugerencias inteligentes',
              subtitle: 'Mostrar sugerencias de respuesta',
              value: smartSuggestions,
              onChanged: (value) {
                setState(() {
                  smartSuggestions = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildSwitchTile(
              icon: Icons.memory,
              title: 'Consciencia de contexto',
              subtitle: 'El asistente recuerda la conversación',
              value: contextAwareness,
              onChanged: (value) {
                setState(() {
                  contextAwareness = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(ThemeData theme, ColorScheme colorScheme) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.text_fields,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamaño de fuente',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${fontSize.round()}px',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Texto de ejemplo con el tamaño seleccionado',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSpeedSlider(ThemeData theme, ColorScheme colorScheme) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.speed,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Velocidad de respuesta',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      _getSpeedText(messageSpeed),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: messageSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              onChanged: (value) {
                setState(() {
                  messageSpeed = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleStyleSelector(ThemeData theme, ColorScheme colorScheme) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Estilo de burbujas',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBubbleOption(
                  'rounded',
                  'Redondeadas',
                  theme,
                  colorScheme,
                  BorderRadius.circular(20),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildBubbleOption(
                  'square',
                  'Cuadradas',
                  theme,
                  colorScheme,
                  BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleOption(
    String value,
    String label,
    ThemeData theme,
    ColorScheme colorScheme,
    BorderRadius borderRadius,
  ) {
    final isSelected = bubbleStyle == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          bubbleStyle = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: borderRadius,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                  ? colorScheme.primary
                  : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperSelector(ThemeData theme, ColorScheme colorScheme) {
    return _buildSettingsTile(
      icon: Icons.wallpaper,
      title: 'Fondo de chat',
      subtitle: _getWallpaperText(wallpaper),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showWallpaperDialog(context),
      theme: theme,
    );
  }

  Widget _buildPersonalitySelector(ThemeData theme, ColorScheme colorScheme) {
    return _buildSettingsTile(
      icon: Icons.psychology,
      title: 'Personalidad del asistente',
      subtitle: _getPersonalityText(aiPersonality),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showPersonalityDialog(context),
      theme: theme,
    );
  }

  Widget _buildResponseLengthSelector(ThemeData theme, ColorScheme colorScheme) {
    return _buildSettingsTile(
      icon: Icons.format_size,
      title: 'Longitud de respuestas',
      subtitle: _getResponseLengthText(responseLength),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showResponseLengthDialog(context),
      theme: theme,
    );
  }

  Widget _buildDeleteDaysSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12, left: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eliminar después de: $deleteAfterDays días',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildDayOption(7, theme, colorScheme),
              SizedBox(width: 8),
              _buildDayOption(30, theme, colorScheme),
              SizedBox(width: 8),
              _buildDayOption(90, theme, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayOption(int days, ThemeData theme, ColorScheme colorScheme) {
    final isSelected = deleteAfterDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            deleteAfterDays = days;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
              ? colorScheme.primary
              : colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$days días',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                ? colorScheme.onPrimary
                : theme.textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
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

  // Métodos auxiliares para obtener texto descriptivo
  String _getSpeedText(double speed) {
    if (speed <= 0.5) return 'Muy lenta';
    if (speed <= 1.0) return 'Normal';
    if (speed <= 1.5) return 'Rápida';
    return 'Muy rápida';
  }

  String _getWallpaperText(String wallpaper) {
    switch (wallpaper) {
      case 'default': return 'Por defecto';
      case 'dark': return 'Oscuro';
      case 'gradient': return 'Degradado';
      case 'custom': return 'Personalizado';
      default: return 'Por defecto';
    }
  }

  String _getPersonalityText(String personality) {
    switch (personality) {
      case 'friendly': return 'Amigable';
      case 'professional': return 'Profesional';
      case 'casual': return 'Casual';
      case 'creative': return 'Creativo';
      default: return 'Amigable';
    }
  }

  String _getResponseLengthText(String length) {
    switch (length) {
      case 'short': return 'Cortas';
      case 'balanced': return 'Equilibradas';
      case 'detailed': return 'Detalladas';
      default: return 'Equilibradas';
    }
  }

  // Métodos para mostrar diálogos
  void _showWallpaperDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Fondo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...['default', 'dark', 'gradient', 'custom'].map((option) =>
              ListTile(
                title: Text(_getWallpaperText(option)),
                trailing: wallpaper == option 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
                onTap: () {
                  setState(() {
                    wallpaper = option;
                  });
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  void _showPersonalityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Personalidad del Asistente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...['friendly', 'professional', 'casual', 'creative'].map((option) =>
              ListTile(
                title: Text(_getPersonalityText(option)),
                trailing: aiPersonality == option 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
                onTap: () {
                  setState(() {
                    aiPersonality = option;
                  });
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  void _showResponseLengthDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Longitud de Respuestas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...['short', 'balanced', 'detailed'].map((option) =>
              ListTile(
                title: Text(_getResponseLengthText(option)),
                trailing: responseLength == option 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
                onTap: () {
                  setState(() {
                    responseLength = option;
                  });
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar Conversaciones'),
        content: Text('¿Qué formato prefieres para exportar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TXT'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Borrar Historial'),
        content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restaurar Configuración'),
        content: Text('¿Restaurar todos los valores por defecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                fontSize = 16.0;
                bubbleStyle = 'rounded';
                wallpaper = 'default';
                showTimestamps = true;
                show24HourFormat = false;
                soundEnabled = true;
                vibrationEnabled = true;
                readReceipts = true;
                typingIndicators = true;
                autoScroll = true;
                messageSpeed = 1.0;
                autoDeleteMessages = false;
                deleteAfterDays = 30;
                encryptMessages = true;
                saveHistory = true;
                aiPersonality = 'friendly';
                responseLength = 'balanced';
                smartSuggestions = true;
                contextAwareness = true;
              });
              Navigator.pop(context);
            },
            child: Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}