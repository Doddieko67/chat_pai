// lib/screens/chat_list_screen.dart
import 'package:chat_pai/widgets/chat_list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_pai/widgets/chat_list_widgets.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  late TabController tabController;
  
  // Estados y filtros
  bool isLoading = false;
  bool isSearching = false;
  List<ChatItem> allChats = [];
  List<ChatItem> filteredChats = [];
  Set<String> selectedChats = {};
  bool isSelectionMode = false;
  
  // Filtros
  Set<ChatType> selectedChatTypes = {};
  bool showOnlineOnly = false;
  bool showUnreadOnly = false;
  bool showMutedChats = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    _loadChats();
    searchController.addListener(_filterChats);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(theme, colorScheme),
      body: Column(
        children: [
          // Barra de búsqueda
          if (isSearching) _buildSearchBar(),
          
          // Tabs
          _buildTabBar(theme, colorScheme),
          
          // Lista de chats
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildChatList(ChatType.individual),
                _buildChatList(ChatType.group),
                _buildChatList(ChatType.therapist),
                _buildChatList(ChatType.ai),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
      bottomNavigationBar: isSelectionMode ? _buildSelectionBottomBar(theme, colorScheme) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${selectedChats.length} seleccionados'),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: _selectAllChats,
          ),
        ],
      );
    }

    return AppBar(
      title: Text('Chats'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.tune),
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
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'archived',
              child: ListTile(
                leading: Icon(Icons.archive),
                title: Text('Chats archivados'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'new_group',
              child: ListTile(
                leading: Icon(Icons.group_add),
                title: Text('Nuevo grupo'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ChatSearchBar(
      controller: searchController,
      hintText: 'Buscar en chats...',
      onClear: () {
        searchController.clear();
      },
      onChanged: (value) {
        _filterChats();
      },
      onFilterTap: _showFiltersBottomSheet,
    );
  }

  Widget _buildTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        indicatorColor: colorScheme.primary,
        onTap: (index) {
          _filterChats();
        },
        tabs: [
          Tab(
            child: _buildTabWithBadge(
              'Personal',
              _getUnreadCount(ChatType.individual),
              colorScheme,
            ),
          ),
          Tab(
            child: _buildTabWithBadge(
              'Grupos',
              _getUnreadCount(ChatType.group),
              colorScheme,
            ),
          ),
          Tab(
            child: _buildTabWithBadge(
              'Terapeutas',
              _getUnreadCount(ChatType.therapist),
              colorScheme,
            ),
          ),
          Tab(
            child: _buildTabWithBadge(
              'IA',
              _getUnreadCount(ChatType.ai),
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String title, int unreadCount, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        if (unreadCount > 0) ...[
          SizedBox(width: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChatList(ChatType filterType) {
    final chatsForType = filteredChats
        .where((chat) => chat.chatType == filterType)
        .toList();

    if (isLoading) {
      return ChatListSkeleton();
    }

    if (chatsForType.isEmpty) {
      return EmptyChatState(
        title: _getEmptyStateTitle(filterType),
        subtitle: _getEmptyStateSubtitle(filterType),
        onCreateChat: () => _showNewChatDialog(filterType),
        actionText: _getNewChatButtonText(filterType),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.builder(
        itemCount: chatsForType.length,
        itemBuilder: (context, index) {
          final chat = chatsForType[index];
          return Dismissible(
            key: Key(chat.id),
            direction: DismissDirection.horizontal,
            background: _buildDismissBackground(true),
            secondaryBackground: _buildDismissBackground(false),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                // Deslizar hacia la izquierda - Archivar
                return await _showArchiveDialog(chat);
              } else {
                // Deslizar hacia la derecha - Silenciar
                _toggleMuteChat(chat);
                return false;
              }
            },
            child: ChatListItem(
              chat: chat,
              isSelected: selectedChats.contains(chat.id),
              onTap: () {
                if (isSelectionMode) {
                  _toggleChatSelection(chat.id);
                } else {
                  _openChat(chat);
                }
              },
              onLongPress: () {
                if (!isSelectionMode) {
                  _enterSelectionMode(chat.id);
                }
              },
              onMute: () => _toggleMuteChat(chat),
              onArchive: () => _archiveChat(chat),
              onPin: () => _togglePinChat(chat),
              onDelete: () => _showDeleteDialog(chat),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground(bool isLeftSwipe) {
    return Container(
      color: isLeftSwipe ? Colors.orange : Colors.red,
      alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isLeftSwipe ? Icons.volume_off : Icons.archive,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: () => _showNewChatDialog(null),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: Icon(Icons.add),
    );
  }

  Widget _buildSelectionBottomBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAction(
            icon: Icons.archive,
            label: 'Archivar',
            onTap: _archiveSelectedChats,
          ),
          _buildBottomAction(
            icon: Icons.volume_off,
            label: 'Silenciar',
            onTap: _muteSelectedChats,
          ),
          _buildBottomAction(
            icon: Icons.push_pin,
            label: 'Fijar',
            onTap: _pinSelectedChats,
          ),
          _buildBottomAction(
            icon: Icons.delete,
            label: 'Eliminar',
            onTap: _deleteSelectedChats,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de carga y filtrado
  Future<void> _loadChats() async {
    setState(() {
      isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(Duration(seconds: 1));

    // Datos de ejemplo
    allChats = [
      ChatItem(
        id: '1',
        name: 'Dra. María González',
        subtitle: null,
        avatarUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        lastMessage: 'Hola, ¿cómo te has sentido esta semana?',
        lastMessageType: MessageType.text,
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        lastMessageStatus: MessageStatus.read,
        unreadCount: 2,
        isOnline: true,
        onlineStatus: OnlineStatus.online,
        isMuted: false,
        isArchived: false,
        isPinned: true,
        isTyping: false,
        chatType: ChatType.therapist,
        therapistSpecialty: 'Psicóloga Clínica',
      ),
      ChatItem(
        id: '2',
        name: 'Asistente IA',
        subtitle: null,
        avatarUrl: '',
        lastMessage: '¿En qué puedo ayudarte hoy?',
        lastMessageType: MessageType.text,
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 15)),
        lastMessageStatus: MessageStatus.delivered,
        unreadCount: 0,
        isOnline: true,
        onlineStatus: OnlineStatus.online,
        isMuted: false,
        isArchived: false,
        isPinned: false,
        isTyping: true,
        chatType: ChatType.ai,
      ),
      ChatItem(
        id: '3',
        name: 'Ana Martínez',
        subtitle: null,
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b6f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        lastMessage: 'Gracias por la sesión de ayer',
        lastMessageType: MessageType.text,
        lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
        lastMessageStatus: MessageStatus.read,
        unreadCount: 0,
        isOnline: false,
        onlineStatus: OnlineStatus.offline,
        isMuted: false,
        isArchived: false,
        isPinned: false,
        isTyping: false,
        chatType: ChatType.individual,
      ),
      ChatItem(
        id: '4',
        name: 'Grupo de Apoyo',
        subtitle: '12 participantes',
        avatarUrl: '',
        lastMessage: 'Carlos: Me siento mucho mejor',
        lastMessageType: MessageType.text,
        lastMessageTime: DateTime.now().subtract(Duration(hours: 3)),
        lastMessageStatus: MessageStatus.delivered,
        unreadCount: 5,
        isOnline: false,
        onlineStatus: OnlineStatus.offline,
        isMuted: true,
        isArchived: false,
        isPinned: false,
        isTyping: false,
        chatType: ChatType.group,
        groupMemberAvatars: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        ],
      ),
      ChatItem(
        id: '5',
        name: 'Dr. Carlos Ruiz',
        subtitle: null,
        avatarUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80',
        lastMessage: 'Imagen',
        lastMessageType: MessageType.image,
        lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
        lastMessageStatus: MessageStatus.read,
        unreadCount: 0,
        isOnline: true,
        onlineStatus: OnlineStatus.away,
        isMuted: false,
        isArchived: false,
        isPinned: false,
        isTyping: false,
        chatType: ChatType.therapist,
        therapistSpecialty: 'Terapeuta de Pareja',
      ),
      ChatItem(
        id: '6',
        name: 'Luis García',
        subtitle: null,
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
        lastMessage: 'Mensaje de voz',
        lastMessageType: MessageType.audio,
        lastMessageTime: DateTime.now().subtract(Duration(days: 2)),
        lastMessageStatus: MessageStatus.delivered,
        unreadCount: 1,
        isOnline: false,
        onlineStatus: OnlineStatus.offline,
        isMuted: false,
        isArchived: false,
        isPinned: false,
        isTyping: false,
        chatType: ChatType.individual,
      ),
    ];

    setState(() {
      isLoading = false;
    });
    
    _filterChats();
  }

  void _filterChats() {
    filteredChats = allChats.where((chat) {
      // Filtro por búsqueda de texto
      if (searchController.text.isNotEmpty) {
        final searchText = searchController.text.toLowerCase();
        if (!chat.name.toLowerCase().contains(searchText) &&
            !chat.lastMessage.toLowerCase().contains(searchText)) {
          return false;
        }
      }

      // Filtro por tipos de chat
      if (selectedChatTypes.isNotEmpty && !selectedChatTypes.contains(chat.chatType)) {
        return false;
      }

      // Filtro por estado online
      if (showOnlineOnly && !chat.isOnline) {
        return false;
      }

      // Filtro por no leídos
      if (showUnreadOnly && chat.unreadCount == 0) {
        return false;
      }

      // Filtro por chats silenciados
      if (!showMutedChats && chat.isMuted) {
        return false;
      }

      // No mostrar archivados en la lista principal
      if (chat.isArchived) {
        return false;
      }

      return true;
    }).toList();

    // Ordenar: primero pinned, luego por hora del último mensaje
    filteredChats.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });

    setState(() {});
  }

  // Métodos de acción
  void _openChat(ChatItem chat) {
    // TODO: Navegar a la pantalla de chat individual
    Navigator.pushNamed(context, '/chat', arguments: chat);
  }

  void _enterSelectionMode(String chatId) {
    setState(() {
      isSelectionMode = true;
      selectedChats.add(chatId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedChats.clear();
    });
  }

  void _toggleChatSelection(String chatId) {
    setState(() {
      if (selectedChats.contains(chatId)) {
        selectedChats.remove(chatId);
        if (selectedChats.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedChats.add(chatId);
      }
    });
  }

  void _selectAllChats() {
    setState(() {
      selectedChats.addAll(filteredChats.map((chat) => chat.id));
    });
  }

  void _toggleMuteChat(ChatItem chat) {
    setState(() {
      final index = allChats.indexWhere((c) => c.id == chat.id);
      if (index >= 0) {
        allChats[index] = ChatItem(
          id: chat.id,
          name: chat.name,
          subtitle: chat.subtitle,
          avatarUrl: chat.avatarUrl,
          lastMessage: chat.lastMessage,
          lastMessageType: chat.lastMessageType,
          lastMessageTime: chat.lastMessageTime,
          lastMessageStatus: chat.lastMessageStatus,
          unreadCount: chat.unreadCount,
          isOnline: chat.isOnline,
          onlineStatus: chat.onlineStatus,
          isMuted: !chat.isMuted,
          isArchived: chat.isArchived,
          isPinned: chat.isPinned,
          isTyping: chat.isTyping,
          chatType: chat.chatType,
          groupMemberAvatars: chat.groupMemberAvatars,
          therapistSpecialty: chat.therapistSpecialty,
        );
      }
    });
    _filterChats();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(chat.isMuted ? 'Chat activado' : 'Chat silenciado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _togglePinChat(ChatItem chat) {
    setState(() {
      final index = allChats.indexWhere((c) => c.id == chat.id);
      if (index >= 0) {
        allChats[index] = ChatItem(
          id: chat.id,
          name: chat.name,
          subtitle: chat.subtitle,
          avatarUrl: chat.avatarUrl,
          lastMessage: chat.lastMessage,
          lastMessageType: chat.lastMessageType,
          lastMessageTime: chat.lastMessageTime,
          lastMessageStatus: chat.lastMessageStatus,
          unreadCount: chat.unreadCount,
          isOnline: chat.isOnline,
          onlineStatus: chat.onlineStatus,
          isMuted: chat.isMuted,
          isArchived: chat.isArchived,
          isPinned: !chat.isPinned,
          isTyping: chat.isTyping,
          chatType: chat.chatType,
          groupMemberAvatars: chat.groupMemberAvatars,
          therapistSpecialty: chat.therapistSpecialty,
        );
      }
    });
    _filterChats();
  }

  Future<bool> _showArchiveDialog(ChatItem chat) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archivar chat'),
        content: Text('¿Estás seguro de que quieres archivar este chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Archivar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _archiveChat(ChatItem chat) {
    setState(() {
      final index = allChats.indexWhere((c) => c.id == chat.id);
      if (index >= 0) {
        allChats[index] = ChatItem(
          id: chat.id,
          name: chat.name,
          subtitle: chat.subtitle,
          avatarUrl: chat.avatarUrl,
          lastMessage: chat.lastMessage,
          lastMessageType: chat.lastMessageType,
          lastMessageTime: chat.lastMessageTime,
          lastMessageStatus: chat.lastMessageStatus,
          unreadCount: chat.unreadCount,
          isOnline: chat.isOnline,
          onlineStatus: chat.onlineStatus,
          isMuted: chat.isMuted,
          isArchived: true,
          isPinned: chat.isPinned,
          isTyping: chat.isTyping,
          chatType: chat.chatType,
          groupMemberAvatars: chat.groupMemberAvatars,
          therapistSpecialty: chat.therapistSpecialty,
        );
      }
    });
    _filterChats();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat archivado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            // TODO: Implementar deshacer
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(ChatItem chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar chat'),
        content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chat);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteChat(ChatItem chat) {
    setState(() {
      allChats.removeWhere((c) => c.id == chat.id);
    });
    _filterChats();
  }

  // Métodos para acciones en lote
  void _archiveSelectedChats() {
    // TODO: Implementar
    _exitSelectionMode();
  }

  void _muteSelectedChats() {
    // TODO: Implementar
    _exitSelectionMode();
  }

  void _pinSelectedChats() {
    // TODO: Implementar
    _exitSelectionMode();
  }

  void _deleteSelectedChats() {
    // TODO: Implementar
    _exitSelectionMode();
  }

  // Métodos auxiliares
  int _getUnreadCount(ChatType type) {
    return allChats
        .where((chat) => chat.chatType == type && chat.unreadCount > 0)
        .fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  String _getEmptyStateTitle(ChatType type) {
    switch (type) {
      case ChatType.individual:
        return 'No hay chats personales';
      case ChatType.group:
        return 'No hay grupos';
      case ChatType.therapist:
        return 'No hay terapeutas';
      case ChatType.ai:
        return 'No hay conversaciones con IA';
    }
  }

  String _getEmptyStateSubtitle(ChatType type) {
    switch (type) {
      case ChatType.individual:
        return 'Inicia una conversación personal';
      case ChatType.group:
        return 'Únete o crea un grupo';
      case ChatType.therapist:
        return 'Contacta con un terapeuta';
      case ChatType.ai:
        return 'Habla con el asistente IA';
    }
  }

  String _getNewChatButtonText(ChatType type) {
    switch (type) {
      case ChatType.individual:
        return 'Nuevo Chat';
      case ChatType.group:
        return 'Crear Grupo';
      case ChatType.therapist:
        return 'Buscar Terapeuta';
      case ChatType.ai:
        return 'Hablar con IA';
    }
  }

  void _showNewChatDialog(ChatType? type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nuevo Chat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Chat personal'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add),
              title: Text('Crear grupo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar
              },
            ),
            ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Buscar terapeuta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/therapists');
              },
            ),
            ListTile(
              leading: Icon(Icons.smart_toy),
              title: Text('Asistente IA'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar
              },
            ),
          ],
        ),
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
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: ChatFilters(
            selectedChatTypes: selectedChatTypes,
            showOnlineOnly: showOnlineOnly,
            showUnreadOnly: showUnreadOnly,
            showMutedChats: showMutedChats,
            onChatTypesChanged: (types) {
              setState(() {
                selectedChatTypes = types;
              });
              _filterChats();
            },
            onOnlineOnlyChanged: (value) {
              setState(() {
                showOnlineOnly = value;
              });
              _filterChats();
            },
            onUnreadOnlyChanged: (value) {
              setState(() {
                showUnreadOnly = value;
              });
              _filterChats();
            },
            onShowMutedChanged: (value) {
              setState(() {
                showMutedChats = value;
              });
              _filterChats();
            },
            onClearFilters: () {
              setState(() {
                selectedChatTypes.clear();
                showOnlineOnly = false;
                showUnreadOnly = false;
                showMutedChats = true;
              });
              _filterChats();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'archived':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArchivedChatsScreen(),
          ),
        );
        break;
      case 'settings':
        Navigator.pushNamed(context, '/chat_settings');
        break;
      case 'new_group':
        _showNewChatDialog(ChatType.group);
        break;
    }
  }

  bool _hasActiveFilters() {
    return selectedChatTypes.isNotEmpty ||
           showOnlineOnly ||
           showUnreadOnly ||
           !showMutedChats;
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }
}

// lib/screens/archived_chats_screen.dart
class ArchivedChatsScreen extends StatefulWidget {
  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  List<ChatItem> archivedChats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats Archivados'),
        actions: [
          if (archivedChats.isNotEmpty)
            IconButton(
              icon: Icon(Icons.unarchive),
              onPressed: _showUnarchiveAllDialog,
            ),
        ],
      ),
      body: isLoading
          ? ChatListSkeleton()
          : archivedChats.isEmpty
              ? EmptyChatState(
                  title: 'No hay chats archivados',
                  subtitle: 'Los chats archivados aparecerán aquí',
                )
              : ListView.builder(
                  itemCount: archivedChats.length,
                  itemBuilder: (context, index) {
                    final chat = archivedChats[index];
                    return ChatListItem(
                      chat: chat,
                      onTap: () {
                        // TODO: Abrir chat
                      },
                      onArchive: () => _unarchiveChat(chat),
                    );
                  },
                ),
    );
  }

  Future<void> _loadArchivedChats() async {
    // Simular carga de chats archivados
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      archivedChats = []; // Aquí cargarías los chats archivados reales
      isLoading = false;
    });
  }

  void _unarchiveChat(ChatItem chat) {
    setState(() {
      archivedChats.removeWhere((c) => c.id == chat.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat restaurado'),
      ),
    );
  }

  void _showUnarchiveAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restaurar todos'),
        content: Text('¿Restaurar todos los chats archivados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                archivedChats.clear();
              });
            },
            child: Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}

// lib/screens/chat_search_screen.dart
class ChatSearchScreen extends StatefulWidget {
  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<ChatItem> searchResults = [];
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar en todos los chats...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              setState(() {
                searchResults.clear();
              });
            },
          ),
        ],
      ),
      body: isSearching
          ? Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? EmptyChatState(
                  title: 'Buscar en chats',
                  subtitle: 'Encuentra mensajes y conversaciones',
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final chat = searchResults[index];
                    return ChatListItem(
                      chat: chat,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Abrir chat y navegar al mensaje
                      },
                    );
                  },
                ),
    );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    // Simular búsqueda
    await Future.delayed(Duration(milliseconds: 500));

    // TODO: Implementar búsqueda real
    setState(() {
      searchResults = []; // Resultados de búsqueda
      isSearching = false;
    });
  }
}