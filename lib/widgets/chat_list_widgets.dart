// lib/widgets/chat_list_widgets.dart
import 'package:flutter/material.dart';

// Enums para diferentes tipos
enum MessageType { text, image, audio, video, document, location }
enum MessageStatus { sending, sent, delivered, read, failed }
enum ChatType { individual, group, therapist, ai }
enum OnlineStatus { online, offline, away, busy }

// Modelo de datos para Chat
class ChatItem {
  final String id;
  final String name;
  final String? subtitle; // Para grupos o descripción de terapeuta
  final String avatarUrl;
  final String lastMessage;
  final MessageType lastMessageType;
  final DateTime lastMessageTime;
  final MessageStatus lastMessageStatus;
  final int unreadCount;
  final bool isOnline;
  final OnlineStatus onlineStatus;
  final bool isMuted;
  final bool isArchived;
  final bool isPinned;
  final bool isTyping;
  final ChatType chatType;
  final List<String>? groupMemberAvatars; // Para grupos
  final String? therapistSpecialty; // Para terapeutas

  ChatItem({
    required this.id,
    required this.name,
    this.subtitle,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.lastMessageStatus,
    required this.unreadCount,
    required this.isOnline,
    required this.onlineStatus,
    required this.isMuted,
    required this.isArchived,
    required this.isPinned,
    required this.isTyping,
    required this.chatType,
    this.groupMemberAvatars,
    this.therapistSpecialty,
  });
}

// Widget 1: Item de Chat Principal
class ChatListItem extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMute;
  final VoidCallback? onArchive;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ChatListItem({
    Key? key,
    required this.chat,
    this.onTap,
    this.onLongPress,
    this.onMute,
    this.onArchive,
    this.onPin,
    this.onDelete,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: isSelected 
        ? colorScheme.primary.withOpacity(0.1)
        : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con indicadores
                Stack(
                  children: [
                    ChatAvatar(
                      imageUrl: chat.avatarUrl,
                      name: chat.name,
                      size: 56,
                      chatType: chat.chatType,
                      groupMemberAvatars: chat.groupMemberAvatars,
                    ),
                    // Indicador online
                    if (chat.isOnline && chat.chatType == ChatType.individual)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: OnlineIndicator(
                          status: chat.onlineStatus,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                
                SizedBox(width: 12),
                
                // Contenido del chat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primera línea: nombre, pin, hora
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (chat.isPinned)
                                  Container(
                                    margin: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.push_pin,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                Flexible(
                                  child: Text(
                                    chat.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: chat.unreadCount > 0 
                                        ? FontWeight.bold 
                                        : FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (chat.chatType == ChatType.therapist)
                                  Container(
                                    margin: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: 8),
                          
                          // Hora y estado del mensaje
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(chat.lastMessageTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: chat.unreadCount > 0
                                    ? colorScheme.primary
                                    : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                  fontWeight: chat.unreadCount > 0 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 2),
                              if (chat.lastMessageStatus != MessageStatus.read)
                                MessageStatusIcon(
                                  status: chat.lastMessageStatus,
                                  size: 16,
                                ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Subtítulo para terapeutas o grupos
                      if (chat.subtitle != null || chat.therapistSpecialty != null) ...[
                        SizedBox(height: 2),
                        Text(
                          chat.subtitle ?? chat.therapistSpecialty ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      SizedBox(height: 4),
                      
                      // Segunda línea: último mensaje, íconos
                      Row(
                        children: [
                          Expanded(
                            child: chat.isTyping
                              ? TypingIndicator()
                              : LastMessagePreview(
                                  message: chat.lastMessage,
                                  type: chat.lastMessageType,
                                  theme: theme,
                                  isUnread: chat.unreadCount > 0,
                                ),
                          ),
                          
                          SizedBox(width: 8),
                          
                          // Indicadores y badges
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (chat.isMuted)
                                Container(
                                  margin: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.volume_off,
                                    size: 16,
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                  ),
                                ),
                              
                              if (chat.unreadCount > 0)
                                UnreadBadge(
                                  count: chat.unreadCount,
                                  isMuted: chat.isMuted,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Hoy: mostrar hora
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Ayer
      return 'Ayer';
    } else if (difference.inDays < 7) {
      // Esta semana: mostrar día
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return weekdays[time.weekday - 1];
    } else {
      // Más de una semana: mostrar fecha
      return '${time.day}/${time.month}';
    }
  }
}

// Widget 2: Avatar de Chat
class ChatAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final ChatType chatType;
  final List<String>? groupMemberAvatars;

  const ChatAvatar({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.size = 56,
    required this.chatType,
    this.groupMemberAvatars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (chatType == ChatType.group && groupMemberAvatars != null && groupMemberAvatars!.length > 1) {
      return _buildGroupAvatar(colorScheme);
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getAvatarColor(colorScheme),
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: (exception, stackTrace) {},
      child: imageUrl.isEmpty ? _getAvatarIcon(colorScheme) : null,
    );
  }

  Widget _buildGroupAvatar(ColorScheme colorScheme) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Avatar principal (más grande)
          Positioned(
            top: 0,
            left: 0,
            child: CircleAvatar(
              radius: size * 0.35,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              backgroundImage: groupMemberAvatars![0].isNotEmpty 
                ? NetworkImage(groupMemberAvatars![0])
                : null,
              child: groupMemberAvatars![0].isEmpty 
                ? Icon(Icons.person, size: size * 0.3, color: colorScheme.primary)
                : null,
            ),
          ),
          // Avatar secundario (más pequeño)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: size * 0.25,
              backgroundColor: colorScheme.secondary.withOpacity(0.1),
              backgroundImage: groupMemberAvatars!.length > 1 && groupMemberAvatars![1].isNotEmpty
                ? NetworkImage(groupMemberAvatars![1])
                : null,
              child: groupMemberAvatars!.length <= 1 || groupMemberAvatars![1].isEmpty
                ? Icon(Icons.person, size: size * 0.2, color: colorScheme.secondary)
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(ColorScheme colorScheme) {
    switch (chatType) {
      case ChatType.ai:
        return colorScheme.primary.withOpacity(0.1);
      case ChatType.therapist:
        return Colors.blue.withOpacity(0.1);
      case ChatType.group:
        return colorScheme.secondary.withOpacity(0.1);
      default:
        return colorScheme.primary.withOpacity(0.1);
    }
  }

  Widget _getAvatarIcon(ColorScheme colorScheme) {
    IconData icon;
    Color iconColor;

    switch (chatType) {
      case ChatType.ai:
        icon = Icons.smart_toy;
        iconColor = colorScheme.primary;
        break;
      case ChatType.therapist:
        icon = Icons.psychology;
        iconColor = Colors.blue;
        break;
      case ChatType.group:
        icon = Icons.group;
        iconColor = colorScheme.secondary;
        break;
      default:
        icon = Icons.person;
        iconColor = colorScheme.primary;
    }

    return Icon(
      icon,
      size: size * 0.5,
      color: iconColor,
    );
  }
}

// Widget 3: Indicador Online
class OnlineIndicator extends StatelessWidget {
  final OnlineStatus status;
  final double size;

  const OnlineIndicator({
    Key? key,
    required this.status,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    
    switch (status) {
      case OnlineStatus.online:
        color = Colors.green;
        break;
      case OnlineStatus.away:
        color = Colors.orange;
        break;
      case OnlineStatus.busy:
        color = Colors.red;
        break;
      case OnlineStatus.offline:
        color = Colors.grey;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }
}

// Widget 4: Badge de Mensajes No Leídos
class UnreadBadge extends StatelessWidget {
  final int count;
  final bool isMuted;

  const UnreadBadge({
    Key? key,
    required this.count,
    this.isMuted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (count == 0) return SizedBox.shrink();

    final backgroundColor = isMuted 
      ? colorScheme.outline
      : colorScheme.primary;
    
    final textColor = isMuted
      ? colorScheme.surface
      : colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: count > 99 ? 6 : 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Widget 5: Preview del Último Mensaje
class LastMessagePreview extends StatelessWidget {
  final String message;
  final MessageType type;
  final ThemeData theme;
  final bool isUnread;

  const LastMessagePreview({
    Key? key,
    required this.message,
    required this.type,
    required this.theme,
    this.isUnread = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        if (type != MessageType.text) ...[
          Icon(
            _getMessageTypeIcon(),
            size: 16,
            color: colorScheme.primary,
          ),
          SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            _getMessageText(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isUnread
                ? theme.textTheme.bodyMedium?.color
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  IconData _getMessageTypeIcon() {
    switch (type) {
      case MessageType.image:
        return Icons.image;
      case MessageType.audio:
        return Icons.mic;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.document:
        return Icons.description;
      case MessageType.location:
        return Icons.location_on;
      default:
        return Icons.message;
    }
  }

  String _getMessageText() {
    switch (type) {
      case MessageType.image:
        return 'Imagen';
      case MessageType.audio:
        return 'Mensaje de voz';
      case MessageType.video:
        return 'Video';
      case MessageType.document:
        return 'Documento';
      case MessageType.location:
        return 'Ubicación';
      default:
        return message;
    }
  }
}

// Widget 6: Indicador de Estado del Mensaje
class MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;
  final double size;

  const MessageStatusIcon({
    Key? key,
    required this.status,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = colorScheme.outline;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = colorScheme.outline;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = colorScheme.outline;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}

// Widget 7: Indicador de Escritura
class TypingIndicator extends StatefulWidget {
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          Icons.edit,
          size: 16,
          color: colorScheme.primary,
        ),
        SizedBox(width: 4),
        Text(
          'Escribiendo',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(width: 4),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (index) {
                final delay = index * 0.3;
                final opacity = (_animation.value + delay) % 1.0;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  child: Opacity(
                    opacity: opacity > 0.5 ? 1.0 - opacity : opacity * 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Widget 8: Barra de Búsqueda de Chats
class ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const ChatSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Buscar chats...',
    this.onClear,
    this.onChanged,
    this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            SizedBox(width: 8),
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(Icons.tune),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                foregroundColor: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget 9: Filtros de Chat
class ChatFilters extends StatelessWidget {
  final Set<ChatType> selectedChatTypes;
  final bool showOnlineOnly;
  final bool showUnreadOnly;
  final bool showMutedChats;
  final Function(Set<ChatType>) onChatTypesChanged;
  final Function(bool) onOnlineOnlyChanged;
  final Function(bool) onUnreadOnlyChanged;
  final Function(bool) onShowMutedChanged;
  final VoidCallback onClearFilters;

  const ChatFilters({
    Key? key,
    required this.selectedChatTypes,
    required this.showOnlineOnly,
    required this.showUnreadOnly,
    required this.showMutedChats,
    required this.onChatTypesChanged,
    required this.onOnlineOnlyChanged,
    required this.onUnreadOnlyChanged,
    required this.onShowMutedChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filtros de Chat',
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
          
          // Tipos de chat
          Text(
            'Tipos de Chat',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ChatType.values.map((type) {
              final isSelected = selectedChatTypes.contains(type);
              return FilterChip(
                label: Text(_getChatTypeLabel(type)),
                selected: isSelected,
                onSelected: (selected) {
                  final newSelection = Set<ChatType>.from(selectedChatTypes);
                  if (selected) {
                    newSelection.add(type);
                  } else {
                    newSelection.remove(type);
                  }
                  onChatTypesChanged(newSelection);
                },
                selectedColor: colorScheme.primary.withOpacity(0.2),
                checkmarkColor: colorScheme.primary,
              );
            }).toList(),
          ),
          
          SizedBox(height: 24),
          
          // Opciones adicionales
          Text(
            'Filtros Adicionales',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          
          SwitchListTile(
            title: Text('Solo contactos en línea'),
            subtitle: Text('Mostrar únicamente usuarios activos'),
            value: showOnlineOnly,
            onChanged: onOnlineOnlyChanged,
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          
          SwitchListTile(
            title: Text('Solo no leídos'),
            subtitle: Text('Mostrar únicamente chats con mensajes nuevos'),
            value: showUnreadOnly,
            onChanged: onUnreadOnlyChanged,
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          
          SwitchListTile(
            title: Text('Incluir chats silenciados'),
            subtitle: Text('Mostrar chats que tienes silenciados'),
            value: showMutedChats,
            onChanged: onShowMutedChanged,
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _getChatTypeLabel(ChatType type) {
    switch (type) {
      case ChatType.individual:
        return 'Personal';
      case ChatType.group:
        return 'Grupos';
      case ChatType.therapist:
        return 'Terapeutas';
      case ChatType.ai:
        return 'Asistente IA';
    }
  }
}

// Widget 10: Skeleton Loader para Chats
class ChatListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar skeleton
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              
              SizedBox(width: 12),
              
              // Contenido skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Nombre skeleton
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Spacer(),
                        // Hora skeleton
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Mensaje skeleton
                    Container(
                      width: double.infinity,
                      height: 14,
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
        );
      },
    );
  }
}

// Widget 11: Estado Vacío para Chats
class EmptyChatState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onCreateChat;
  final String? actionText;

  const EmptyChatState({
    Key? key,
    this.title = 'No hay chats disponibles',
    this.subtitle = 'Inicia una conversación para comenzar',
    this.onCreateChat,
    this.actionText = 'Nuevo Chat',
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
                Icons.chat_bubble_outline,
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
            if (onCreateChat != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onCreateChat,
                icon: Icon(Icons.add),
                label: Text(actionText!),
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