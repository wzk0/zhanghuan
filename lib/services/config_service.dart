import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/semester_config.dart';

class ConfigService {
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/wzk0/zhic_tool/main/config.json';
  static const String _cacheKey = 'semester_configs_cache';
  Future<List<SemesterConfig>> fetchConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        await prefs.setString(_cacheKey, response.body);
        return data.map((e) => SemesterConfig.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("远程配置读取失败，尝试使用本地缓存: $e");
    }
    final String? cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      return [
        SemesterConfig(name: "2025-2026-1", id: "82", startDate: "2025-09-08"),
        SemesterConfig(name: "2024-2025-2", id: "81", startDate: "2025-03-03"),
        SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
        SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
        SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
        SemesterConfig(name: "2023-2024-2", id: "42", startDate: "2024-03-04"),
        SemesterConfig(name: "2023-2024-1", id: "41", startDate: "2023-09-04"),
      ];
    }
    return [
      SemesterConfig(name: "2025-2026-1", id: "82", startDate: "2025-09-08"),
      SemesterConfig(name: "2024-2025-2", id: "81", startDate: "2025-03-03"),
      SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
      SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
      SemesterConfig(name: "2024-2025-1", id: "61", startDate: "2024-09-02"),
      SemesterConfig(name: "2023-2024-2", id: "42", startDate: "2024-03-04"),
      SemesterConfig(name: "2023-2024-1", id: "41", startDate: "2023-09-04"),
    ];
  }
}
