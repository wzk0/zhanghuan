import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // 设置项变量
  bool _showSunday = false;
  bool _directToDesktop = false;

  // Tooltip 设置项 (可以用 Map 存储)
  final Map<String, bool> _tooltipSettings = {
    '授课老师': true,
    '上课时间': true,
    '上课节数': true,
    '课程学时': true,
    '课程学分': true,
  };

  @override
  void initState() {
    super.initState();
    _colors.forEach((name, color) {
      if (color == ThemeManager().current) _selected = name;
    });
    _loadAllSettings();
  }

  // 加载所有持久化设置
  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showSunday = prefs.getBool('show_sunday') ?? false;
      _directToDesktop = prefs.getBool('direct_to_desktop') ?? false;

      // 加载 Tooltip 复选框状态
      for (var key in _tooltipSettings.keys) {
        _tooltipSettings[key] = prefs.getBool('tooltip_$key') ?? true;
      }
    });
  }

  // 保存布尔值设置
  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
      children: [
        // 主题设置部分
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [const Text('主题色')],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 5,
                children: _colors.entries
                    .map((e) => _colorCircle(e.key, e.value))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [const Text('预览')],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ListTile(
                        dense: true,
                        leading: IconButton.filledTonal(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                        title: const Text('Hello'),
                        subtitle: const Text('World'),
                        trailing: Switch(value: true, onChanged: (value) {}),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 课表显示周日设置
        _buildSwitchTile(
          title: '是否在课表中显示周日',
          subtitle: '开启后课表将显示周日(可能会有课程调休至周日)',
          value: _showSunday,
          onChanged: (value) {
            setState(() => _showSunday = value);
            _saveBoolSetting('show_sunday', value);
          },
        ),
        const SizedBox(height: 10),

        // 直接返回桌面设置
        _buildSwitchTile(
          title: '是否直接返回至桌面',
          subtitle: '不开启则侧滑返回会先回到首页',
          value: _directToDesktop,
          onChanged: (value) {
            setState(() => _directToDesktop = value);
            _saveBoolSetting('direct_to_desktop', value);
          },
        ),
        const SizedBox(height: 10),

        // Tooltip 设置
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tooltip内容'),
                  SizedBox(height: 2),
                  Text(
                    '点击课程块后显示的小弹窗内容(过多可能不显示)',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                offset: const Offset(12, -260),
                itemBuilder: (context) {
                  return _tooltipSettings.keys.map((String key) {
                    return PopupMenuItem(
                      child: StatefulBuilder(
                        // 保证弹窗内点击能实时更新UI
                        builder: (context, setPopupState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(key),
                              Checkbox(
                                value: _tooltipSettings[key],
                                onChanged: (value) {
                                  final newVal = value ?? false;
                                  setPopupState(
                                    () => _tooltipSettings[key] = newVal,
                                  );
                                  setState(
                                    () => _tooltipSettings[key] = newVal,
                                  );
                                  _saveBoolSetting('tooltip_$key', newVal);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 抽取的 Switch 列表组件
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 10)),
            ],
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _colorCircle(String name, Color color) {
    final isSelected = _selected == name;
    return GestureDetector(
      onTap: () async {
        await ThemeManager().setColorByName(name); // 修正为 ThemeManager 调用
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
