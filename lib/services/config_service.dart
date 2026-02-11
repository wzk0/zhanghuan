import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/semester_config.dart';

class ConfigService {
  // 建议将此 JSON 文件放在 GitHub 或 Gitee 上
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/wzk0/zhic_tool/main/config.json';
  static const String _cacheKey = 'semester_configs_cache';

  Future<List<SemesterConfig>> fetchConfigs() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. 尝试获取远程数据
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // 保存到本地做缓存
        await prefs.setString(_cacheKey, response.body);
        return data.map((e) => SemesterConfig.fromJson(e)).toList();
      }
    } catch (e) {
      print("远程配置读取失败，尝试使用本地缓存: $e");
    }

    // 2. 远程失败，读取本地缓存
    final String? cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      return [
        SemesterConfig(name: "2026 上学期", id: "82", startDate: "2025-09-08"),
      ];
    }

    // 3. 彻底没网且第一次运行，返回默认兜底数据
    return [
      SemesterConfig(name: "2026 上学期", id: "82", startDate: "2025-09-08"),
    ];
  }
}
