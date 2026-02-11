import 'package:flutter/material.dart';
import 'package:zhanghuan/models/semester_config.dart';
import 'package:zhanghuan/pages/setting/setting.dart';
import 'package:zhanghuan/services/config_service.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  // --- 保留你的原始状态变量 ---
  String _selectedSemester = "加载中..."; // 修改初始值
  bool _isMenuOpen = false;
  int _selectedIndex = 0;

  // --- 新增动态数据变量 ---
  List<SemesterConfig> _remoteSemesters = [];
  SemesterConfig? _currentSelected;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs(); // 初始化时加载数据
  }

  // 动态加载逻辑
  Future<void> _loadConfigs() async {
    final configs = await ConfigService().fetchConfigs();
    if (mounted) {
      setState(() {
        _remoteSemesters = configs;
        if (_remoteSemesters.isNotEmpty) {
          _currentSelected = _remoteSemesters.first;
          _selectedSemester = _currentSelected!.name;
        }
        _isLoading = false;
      });
    }
  }

  final List<Widget> _pages = [
    const Center(child: Text('课表页面')),
    const Center(child: Text('空教室页面')),
    const Center(child: Text('成绩查询页面')),
    const Center(child: Text('考试查询页面')),
    const Center(child: Text('选课页面')),
    const Center(child: Text('评教页面')),
    const Center(child: Text('请假页面')),
    Setting(),
    const Center(child: Text('帮助页面')),
    const Center(child: Text('关于页面')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      drawer: NavigationDrawer(
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
            Navigator.pop(context);
          });
        },
        selectedIndex: _selectedIndex,
        children: [
          // --- 完全保留你的 Stack 结构 ---
          Stack(
            children: [
              SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        child: Text(
                          '王',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text('王卓可'),
                      Text(
                        '自动化工程系 23智能电网02',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : PopupMenuButton<SemesterConfig>(
                          offset: const Offset(0, 20),
                          onOpened: () => setState(() => _isMenuOpen = true),
                          onCanceled: () => setState(() => _isMenuOpen = false),
                          onSelected: (config) {
                            setState(() {
                              _currentSelected = config;
                              _selectedSemester = config.name;
                              _isMenuOpen = false;
                            });
                          },
                          itemBuilder: (context) => _remoteSemesters
                              .map(
                                (s) => PopupMenuItem<SemesterConfig>(
                                  value: s,
                                  child: Text(
                                    s.name,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedSemester,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 3),
                              AnimatedRotation(
                                turns: _isMenuOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 8,
                top: 30,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  child: const Text(
                    '2301080214',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('首页│课表'),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.hdr_weak),
            label: Text('空教室查询'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.saved_search),
            label: Text('成绩查询'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.manage_search),
            label: Text('考试查询'),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.class_outlined),
            label: Text('选课'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.point_of_sale),
            label: Text('评教'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.directions_car_filled_outlined),
            label: Text('请假'),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings_outlined),
            label: Text('设置'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.help_outline),
            label: Text('帮助'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.info_outline),
            label: Text('关于'),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(_currentTitle, style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(onPressed: _loadConfigs, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.login)),
        ],
      ),
    );
  }

  String get _currentTitle {
    const titles = [
      '掌环',
      '掌环│空教室查询',
      '掌环│成绩查询',
      '掌环│考试查询',
      '掌环│选课',
      '掌环│评教',
      '掌环│请假',
      '掌环│设置',
      '掌环│帮助',
      '掌环│关于',
    ];
    return _selectedIndex < titles.length ? titles[_selectedIndex] : '掌环';
  }
}
