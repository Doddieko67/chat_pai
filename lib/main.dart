// lib/main.dart
import 'package:chat_pai/riverpod/auth_provider.dart';
import 'package:chat_pai/screens/chat_screen.dart';
import 'package:chat_pai/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importar tus archivos existentes
import 'package:chat_pai/riverpod/theme_provider.dart';
import 'package:chat_pai/theme/theme.dart';
import 'package:chat_pai/screens/login_screen.dart';
import 'package:chat_pai/screens/chat_list_screen.dart';
import 'package:chat_pai/screens/therapist_list_screen.dart';
import 'package:chat_pai/screens/therapist_profile_screen.dart';
import 'package:chat_pai/screens/chat_settings_screen.dart';
import 'package:chat_pai/widgets/therapist_widgets.dart';

// Importar el sistema de autenticación
import 'riverpod/auth_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Chat Interactivo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode == ThemeModeType.light
          ? ThemeMode.light
          : ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => AppShell(),
        '/chat_list': (context) => ChatListScreen(),
        '/therapists': (context) => TherapistListScreen(),
        '/profile_settings': (context) => ProfileSettingsScreen(),
        '/chat_settings': (context) => ChatSettingsScreen(),
        '/archived_chats': (context) => ArchivedChatsScreen(),
        '/chat_search': (context) => ChatSearchScreen(),
      },
      onGenerateRoute: (settings) {
        // Manejar rutas con parámetros
        if (settings.name?.startsWith('/therapist/') == true) {
          final therapistId = settings.name!.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => TherapistDetailScreen(
              therapist: _getMockTherapist(therapistId),
            ),
          );
        }
        
        if (settings.name?.startsWith('/therapist_profile/') == true) {
          final therapistId = settings.name!.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => TherapistProfileScreen(
              therapistId: therapistId,
            ),
          );
        }
        
        if (settings.name?.startsWith('/chat/') == true) {
          final chatId = settings.name!.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => ChatScreen(),
          );
        }
        
        return null;
      },
    );
  }
  
  // Mock data helper
  Therapist _getMockTherapist(String id) {
    return Therapist(
      id: id,
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
    );
  }
}

// Wrapper que maneja la autenticación
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Si está cargando, mostrar pantalla de carga
    if (authState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando...'),
            ],
          ),
        ),
      );
    }
    
    // Si está autenticado, mostrar la app principal
    if (authState.isAuthenticated && authState.user != null) {
      return AppShell();
    }
    
    // Si no está autenticado, mostrar login
    return AuthenticationScreen();
  }
}

// Pantalla de selección entre Login y Registro
class AuthenticationScreen extends StatefulWidget {
  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con botones de selección
            Container(
              margin: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => showLogin = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showLogin 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                        foregroundColor: showLogin 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                        elevation: showLogin ? 2 : 0,
                      ),
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => showLogin = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !showLogin 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                        foregroundColor: !showLogin 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                        elevation: !showLogin ? 2 : 0,
                      ),
                      child: Text('Registrarse'),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido principal
            Expanded(
              child: showLogin 
                ? LoginScreen(onSwitchToRegister: () => setState(() => showLogin = false))
                : RegisterScreen(onSwitchToLogin: () => setState(() => showLogin = true)),
            ),
          ],
        ),
      ),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int currentIndex = 0;
  PageController pageController = PageController();

  final List<ScreenInfo> screens = [
    ScreenInfo(
      title: 'Chats',
      icon: Icons.chat,
      widget: ChatListScreen(),
    ),
    ScreenInfo(
      title: 'Terapeutas',
      icon: Icons.psychology,
      widget: TherapistListScreen(),
    ),
    ScreenInfo(
      title: 'Perfil',
      icon: Icons.person,
      widget: ProfileSettingsScreen(),
    ),
    ScreenInfo(
      title: 'Configuración',
      icon: Icons.settings,
      widget: ChatSettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(screens[currentIndex].title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/chat_search');
            },
          ),
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeModeType.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  ref.read(themeModeProvider) == ThemeModeType.light
                      ? ThemeModeType.dark
                      : ThemeModeType.light;
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'archived':
                  Navigator.pushNamed(context, '/archived_chats');
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
                case 'debug':
                  _showDebugInfo();
                  break;
              }
            },
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
                value: 'debug',
                child: ListTile(
                  leading: Icon(Icons.bug_report),
                  title: Text('Debug Info'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar información del usuario autenticado
          if (user != null)
            Container(
              width: double.infinity,
              color: colorScheme.primaryContainer,
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido, ${user.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Contenido principal
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: screens.map((screen) => screen.widget).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          items: screens.map((screen) {
            return BottomNavigationBarItem(
              icon: Icon(screen.icon),
              label: screen.title,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (currentIndex == 0) { // Chats tab
      return FloatingActionButton(
        onPressed: () {
          _showNewChatDialog();
        },
        child: Icon(Icons.add),
      );
    } else if (currentIndex == 1) { // Therapists tab
      return FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Filtros de terapeutas')),
          );
        },
        icon: Icon(Icons.filter_list),
        label: Text('Filtros'),
      );
    }
    return null;
  }

  void _showNewChatDialog() {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Iniciando chat personal...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Buscar terapeuta'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentIndex = 1;
                });
                pageController.animateToPage(1,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.smart_toy),
              title: Text('Asistente IA'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Conectando con IA...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
              ref.read(authProvider.notifier).logout();
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

  void _showDebugInfo() {
    final users = AuthService.getRegisteredUsers();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug - Usuarios Registrados'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total de usuarios: ${users.length}'),
              SizedBox(height: 8),
              if (users.isEmpty)
                Text('No hay usuarios registrados')
              else
                ...users.entries.map((entry) {
                  final user = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: Text('ID: ${entry.key.substring(0, 8)}...'),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class ScreenInfo {
  final String title;
  final IconData icon;
  final Widget widget;

  ScreenInfo({
    required this.title,
    required this.icon,
    required this.widget,
  });
}