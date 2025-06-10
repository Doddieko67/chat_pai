// ==================== ARCHIVO: main.dart ====================
import 'package:chat_pai/riverpod/theme_provider.dart';
import 'package:chat_pai/screen/chat_screen.dart';
import 'package:chat_pai/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_pai/riverpod/theme_provider.dart';
// import 'package:chat_pai/themes/app_themes.dart';
// import 'package:chat_pai/screens/chat_screen.dart';

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
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}