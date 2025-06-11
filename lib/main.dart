// main.dart
import 'package:chat_pai/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importar tus archivos existentes
import 'package:chat_pai/riverpod/theme_provider.dart';
import 'package:chat_pai/theme/theme.dart';
import 'package:chat_pai/screens/login_screen.dart';
import 'package:chat_pai/screens/chat_list_screen.dart';
import 'package:chat_pai/screens/therapist_list_screen.dart';
import 'package:chat_pai/screens/chat_settings_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Chat Interactivo - Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode == ThemeModeType.light
          ? ThemeMode.light
          : ThemeMode.dark,
      home: AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int currentIndex = 0;
  PageController pageController = PageController();

  final List<ScreenInfo> screens = [
    ScreenInfo(
      title: 'Autenticación',
      icon: Icons.login,
      widget: AuthenticationDemo(),
    ),
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
      title: 'Chat Config',
      icon: Icons.settings,
      widget: ChatSettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(screens[currentIndex].title),
        actions: [
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
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: screens.map((screen) => screen.widget).toList(),
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
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          items: screens.map((screen) {
            return BottomNavigationBarItem(
              icon: Icon(screen.icon),
              label: screen.title,
            );
          }).toList(),
        ),
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

// Solo para el demo de login/register
class AuthenticationDemo extends StatefulWidget {
  @override
  State<AuthenticationDemo> createState() => _AuthenticationDemoState();
}

class _AuthenticationDemoState extends State<AuthenticationDemo> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle entre Login y Register
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
                  ),
                  child: Text('Login'),
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
                  ),
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: showLogin ? LoginScreen() : RegisterScreen(),
        ),
      ],
    );
  }
}