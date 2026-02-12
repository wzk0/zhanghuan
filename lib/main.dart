import 'package:flutter/material.dart';
import 'package:zhanghuan/themes/theme_manager.dart';
import 'widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (_, _) => MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: ThemeManager().current,
          fontFamily: 'MiSans',
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: ThemeManager().current,
          brightness: Brightness.dark,
          fontFamily: 'MiSans',
        ),
        home: const WidgetTree(),
      ),
    );
  }
}
