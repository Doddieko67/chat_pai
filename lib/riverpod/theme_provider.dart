// ==================== ARCHIVO: theme_provider.dart ====================
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeType { light, dark }

class ThemeModeNotifier extends StateNotifier<ThemeModeType> {
  ThemeModeNotifier() : super(ThemeModeType.light);

  void toggleTheme() {
    state = state == ThemeModeType.light ? ThemeModeType.dark : ThemeModeType.light;
  }
  
  void setLightTheme() {
    state = ThemeModeType.light;
  }
  
  void setDarkTheme() {
    state = ThemeModeType.dark;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeModeType>(
  (ref) => ThemeModeNotifier(),
);
