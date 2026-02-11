import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zhanghuan/models/semester_config.dart';
import 'package:zhanghuan/pages/about/about.dart';
import 'package:zhanghuan/pages/comment/comment.dart';
import 'package:zhanghuan/pages/empty_room/empty_room.dart';
import 'package:zhanghuan/pages/exam/exam.dart';
import 'package:zhanghuan/pages/help/help.dart';
import 'package:zhanghuan/pages/login/login.dart';
import 'package:zhanghuan/pages/score/score.dart';
import 'package:zhanghuan/pages/select/select.dart';
import 'package:zhanghuan/pages/setting/setting.dart';
import 'package:zhanghuan/pages/vocation/vocation.dart';
import 'package:zhanghuan/services/auth_service.dart';
import 'package:zhanghuan/services/config_service.dart';
import 'package:zhanghuan/services/network_service.dart';
import 'package:zhanghuan/utils/date_util.dart';
import 'package:zhanghuan/widgets/schedule.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedSemester = "加载中...";
  List<SemesterConfig> _remoteSemesters = [];
  List _rawScheduleData = [];
  SemesterConfig? _currentSelected;
  late TabController _tabController;
  Map<String, String> _studentInfo = {"name": "", "code": "...", "info": ""};
  bool _isMenuOpen = false;
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 20, vsync: this);
    _initialSetup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialSetup() async {
    setState(() => _isLoading = true);
    _isLoggedIn = await AuthService.isLoggedIn();
    if (mounted) setState(() {});
    _remoteSemesters = await ConfigService().fetchConfigs();
    if (_remoteSemesters.isNotEmpty) {
      _currentSelected = _remoteSemesters.first;
      _selectedSemester = _currentSelected!.name;
    }
    if (_isLoggedIn) {
      await _loadScheduleData();
    }
    if (_currentSelected != null) {
      final currentWeek = DateUtil.getCurrentWeek(_currentSelected!.startDate);
      if (currentWeek >= 1 && currentWeek <= 20) {
        _tabController.animateTo(currentWeek - 1);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handlePop(bool didPop, dynamic result) async {
    if (didPop) return;
    final prefs = await SharedPreferences.getInstance();
    bool directToDesktop = prefs.getBool('direct_to_desktop') ?? false;
    if (directToDesktop) {
      await SystemNavigator.pop();
    } else {
      if (_selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      } else {
        await SystemNavigator.pop();
      }
    }
  }

  Future<void> _loadScheduleData() async {
    if (!_isLoggedIn || _currentSelected == null) return;
    setState(() => _isSyncing = true);
    String scheduleUrl =
        "https://eams.tjzhic.edu.cn/student/for-std/course-table/semester/${_currentSelected!.id}/print-data?semesterId=${_currentSelected!.id}&hasExperiment=true";
    final data = await NetworkService().request(
      scheduleUrl,
      queryParameters: {},
    );
    if (data != null && mounted) {
      setState(() {
        _rawScheduleData = data['studentTableVms'][0]['activities'] ?? [];
        var student = data['studentTableVms'][0];
        _studentInfo = {
          "name": student['name'] ?? "未知",
          "code": student['code'] ?? "未知",
          "info":
              "${student['department'] ?? ''} ${student['adminclass'] ?? ''}",
        };
      });
    }
    if (mounted) setState(() => _isSyncing = false);
  }

  Future<void> _handleAuthOrRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    if (result == true) {
      final status = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() => _isLoggedIn = status);
        _loadScheduleData();
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _rawScheduleData = [];
        _studentInfo = {"name": "", "code": "...", "info": ""};
      });
      Fluttertoast.showToast(msg: '已登出');
    }
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      if (_isLoading) return const Center(child: CircularProgressIndicator());
      if (!_isLoggedIn) return _buildLoginPlaceholder();
      if (_isSyncing && _rawScheduleData.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: List.generate(20, (i) {
            return Schedule(
              data: _rawScheduleData,
              week: i + 1,
              startDate: _currentSelected?.startDate ?? "2026-02-16",
            );
          }),
        ),
      );
    }

    switch (_selectedIndex) {
      case 1:
        return EmptyRoom(
          week: _tabController.index + 1,
          semesterId:
              int.tryParse(_currentSelected?.id.toString() ?? '82') ?? 82,
        );
      case 2:
        return Score(
          semesterId:
              int.tryParse(_currentSelected?.id.toString() ?? '82') ?? 82,
        );
      case 3:
        return Exam(
          semesterId:
              int.tryParse(_currentSelected?.id.toString() ?? '82') ?? 82,
        );
      case 7:
        return const Setting();
      case 8:
        return const Help();
      case 9:
        return const About();
      default:
        return Center(child: Text(_currentTitle));
    }
  }

  Widget _buildLoginPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_person_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            '登录后即可获取课表',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _handleAuthOrRefresh,
            icon: const Icon(Icons.login),
            label: const Text('立即登录'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dynamicTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentSelected != null)
                Text(
                  _currentSelected!.name,
                  style: const TextStyle(fontSize: 10),
                ),
            ],
          ),
          bottom: _selectedIndex == 0
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: List.generate(20, (i) => Tab(text: '第${i + 1}周')),
                )
              : null,
          actions: [
            IconButton(
              onPressed: _handleAuthOrRefresh,
              icon: Icon(_isLoggedIn ? Icons.refresh : Icons.login),
            ),
            if (_isLoggedIn)
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildDrawer() {
    return NavigationDrawer(
      onDestinationSelected: (value) async {
        // 加上 async
        Navigator.pop(context); // 关闭侧边栏

        if (value == 4 || value == 5 || value == 6) {
          // 定义跳转目标
          Widget targetPage;
          if (value == 4) {
            targetPage = const Select();
          } else if (value == 5) {
            targetPage = const Comment();
          } else {
            targetPage = const Vocation();
          }

          // 执行跳转
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );

          // 【关键】当从以上任何一个页面返回后，强制切回首页
          setState(() => _selectedIndex = 0);
        } else {
          // 普通切页
          setState(() => _selectedIndex = value);
        }
      },
      selectedIndex: _selectedIndex,
      children: [
        _buildDrawerHeader(),
        const Divider(),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('首页│课表'),
        ),
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
    );
  }

  Widget _buildDrawerHeader() {
    String name = "未登录";
    String info = "点击右上角按钮登录";
    String code = "...";
    if (_isLoggedIn) {
      if (_isSyncing && _studentInfo['name']!.isEmpty) {
        name = "同步中...";
        info = "正在获取学生信息";
      } else {
        name = _studentInfo['name']!.isEmpty ? "加载失败" : _studentInfo['name']!;
        info = _studentInfo['info']!;
        code = _studentInfo['code']!;
      }
    }
    String avatarText = name.isNotEmpty ? name.substring(0, 1) : "?";
    return Stack(
      children: [
        SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(avatarText, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 5),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(right: 8, top: 5, child: _buildSemesterPicker()),
        Positioned(
          right: 8,
          top: 30,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(code, style: const TextStyle(fontSize: 10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterPicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
                _loadScheduleData();
                final week = DateUtil.getCurrentWeek(config.startDate);
                if (week >= 1 && week <= 20) {
                  _tabController.animateTo(week - 1);
                }
              },
              itemBuilder: (context) => _remoteSemesters
                  .map(
                    (s) => PopupMenuItem<SemesterConfig>(
                      value: s,
                      child: Text(s.name, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedSemester, style: const TextStyle(fontSize: 10)),
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
    );
  }

  String get _currentTitle {
    const titles = [
      '首页│课表',
      '空教室查询',
      '成绩查询',
      '考试查询',
      '选课',
      '评教',
      '请假',
      '设置',
      '帮助',
      '关于',
    ];
    return _selectedIndex < titles.length ? titles[_selectedIndex] : '掌环';
  }

  String get _dynamicTitle {
    if (_selectedIndex != 0) return _currentTitle;
    int viewWeek = _tabController.index + 1;
    if (_currentSelected != null) {
      int realWeek = DateUtil.getCurrentWeek(_currentSelected!.startDate);
      if (realWeek < 1 || realWeek > 20) return "假期中🥤";
      return '第 $viewWeek 周${(viewWeek == realWeek) ? ' (本周)' : ''}';
    }
    return '掌环';
  }
}
