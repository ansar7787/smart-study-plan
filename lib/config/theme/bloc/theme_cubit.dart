import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _prefs.getString(_key);
    if (saved == 'light') emit(ThemeMode.light);
    if (saved == 'dark') emit(ThemeMode.dark);
    // default is system
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    emit(mode);
    await _prefs.setString(_key, isDark ? 'dark' : 'light');
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
