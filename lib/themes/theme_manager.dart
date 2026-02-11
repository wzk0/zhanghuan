import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _key = 'theme_color';

  final _colors = {
    "red": Colors.red,
    "orange": Colors.orange,
    "amber": Colors.amber,
    "yellow": Colors.yellow,
    "lime": Colors.lime,
    "green": Colors.green,
    "teal": Colors.teal,
    "cyan": Colors.cyan,
    "blue": Colors.blue,
    "indigo": Colors.indigo,
    "purple": Colors.purple,
    "pink": Colors.pink,
    "brown": Colors.brown,
    "grey": Colors.grey,
  };

  Color? _current;
  Color? get current => _current;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key) ?? 'blue';
    _current = _colors[name];
    notifyListeners();
  }

  Future<void> setColorByName(String name) async {
    if (!_colors.containsKey(name)) return;
    _current = _colors[name];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name);
    notifyListeners();
  }
}

Future<void> setColorByName(String name) => ThemeManager().setColorByName(name);
