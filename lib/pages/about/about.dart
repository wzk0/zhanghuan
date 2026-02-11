import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'dart:math';
// ignore: library_prefixes
import 'package:url_launcher/url_launcher.dart' as URLLauncher;

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String _currentVersion = "v0.0.0";
  bool _isChecking = false;
  final List<String> _funQuotes = [
    "别点了！",
    "你已经点了 ${Random().nextInt(100)} 次了，不累吗？",
    "再点一下，我就变身了（并没有）",
    "生活明朗，万物可爱，除了教务系统。",
    "今天又是努力的一天呢！",
    "正在加载中环好运气... 100%！",
    '这只猫其实是中环校猫。',
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _currentVersion = "v${packageInfo.version}";
        });
      }
    } catch (e) {
      debugPrint("获取版本号失败: $e");
    }
  }

  Future<void> _checkUpdate() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
    });
    final String currentVersion = _currentVersion;
    const String apiUrl =
        "https://api.github.com/repos/wzk0/zhanghuan/releases/latest";
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestVersion = data['tag_name'];
        final String downloadUrl = data['html_url'];

        if (latestVersion != currentVersion) {
          _showUpdateDialog(latestVersion, downloadUrl);
        } else {
          Fluttertoast.showToast(msg: "当前已是最新版本");
        }
      } else {
        Fluttertoast.showToast(msg: "检查失败：GitHub 连接异常");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "无法连接到服务器，请检查网络");
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _showUpdateDialog(String version, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: Text('检测到新版本 $version，是否前往 GitHub 下载？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              URLLauncher.launchUrl(
                Uri.parse(url),
                mode: URLLauncher.LaunchMode.externalApplication,
              );
            },
            child: const Text('去更新'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              final randomText =
                  _funQuotes[Random().nextInt(_funQuotes.length)];
              Fluttertoast.showToast(msg: randomText);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Image(
                image: AssetImage('assets/images/icon.png'),
                height: 65,
                width: 65,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '掌环 (zhic_tool)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            '当前版本: $_currentVersion',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 22),
        _buildInfoCard(
          context,
          title: '关于掌环',
          content:
              '掌环旨在为天津理工大学中环信息学院的同学们提供更便捷的校园生活体验. 本应用代码全部开源, 不包含任何恶意采集数据的行为. 所有数据来源均来自学校官网公开API.',
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 8, top: 18),
          child: Text(
            '技术栈',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            children: [
              _buildTechChip('Flutter'),
              _buildTechChip('Material 3'),
              _buildTechChip('InAppWebView'),
              _buildTechChip('Shared Preferences'),
              _buildTechChip('Dio/Http'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListTile(
            leading: const Icon(Icons.code),
            title: const Text('项目源代码', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              URLLauncher.launchUrl(
                Uri(
                  scheme: 'https',
                  host: 'github.com',
                  path: '/wzk0/zhanghuan',
                ),
              );
            },
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListTile(
            leading: const Icon(Icons.update),
            title: const Text('检查更新', style: TextStyle(fontSize: 14)),
            trailing: _isChecking
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: _isChecking ? null : _checkUpdate,
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            '© 2025-2026 wzk0 & thdbd.\nAll Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.outline,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
