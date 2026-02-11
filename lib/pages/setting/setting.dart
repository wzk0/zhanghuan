import 'package:flutter/material.dart';
import 'package:zhanghuan/themes/theme_manager.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
  String _selected = 'blue';

  @override
  void initState() {
    super.initState();
    _colors.forEach((name, color) {
      if (color == ThemeManager().current) _selected = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: .start,
                children: [
                  SizedBox(width: 8),
                  const Text('主题色', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: .center,
                spacing: 12,
                runSpacing: 8,
                children: _colors.entries
                    .map((e) => _colorCircle(e.key, e.value))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: .start,
                children: [
                  SizedBox(width: 8),
                  const Text('预览', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                        ),
                        padding: EdgeInsets.all(12),
                        child: ListTile(
                          leading: IconButton.filledTonal(
                            onPressed: () {},
                            icon: Icon(Icons.add),
                          ),
                          title: Text('Hello'),
                          subtitle: Text('World'),
                          trailing: Switch(value: true, onChanged: (value) {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colorCircle(String name, Color color) {
    final isSelected = _selected == name;
    return GestureDetector(
      onTap: () async {
        await setColorByName(name);
        setState(() => _selected = name);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withAlpha(180),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }
}
