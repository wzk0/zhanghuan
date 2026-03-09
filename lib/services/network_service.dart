import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  String _generateCacheKey(Uri uri, Map<String, dynamic>? body) {
    final signStr = uri.toString() + (body?.toString() ?? "");
    return md5.convert(utf8.encode(signStr)).toString();
  }

  Future<dynamic> request(
    String url, {
    bool isPost = false,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }

    final cacheFileName = 'cache-${_generateCacheKey(uri, body)}.json';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookies = prefs.getString('cookies')?.replaceAll('"', '');

      final headers = {
        'Cookie': cookies ?? '',
        'Accept': 'application/json, text/plain, */*',
      };

      http.Response response;
      if (isPost) {
        headers['Content-Type'] = 'application/json;charset=UTF-8';
        response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(timeout);
      } else {
        response = await http.get(uri, headers: headers).timeout(timeout);
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _saveToFile(cacheFileName, decoded);
        return decoded;
      } else {
        debugPrint("服务器返回异常: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("请求超时: $uri");
    } on SocketException {
      debugPrint("网络连接失败，请检查网络设置");
    } catch (e) {
      debugPrint("网络请求发生未知错误: $e");
    }

    debugPrint("正在尝试读取本地缓存文件...");
    return await _loadFromFile(cacheFileName);
  }

  Future<dynamic> getCache(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return await _loadFromFile('cache-${_generateCacheKey(uri, null)}.json');
  }

  Future<void> _saveToFile(String fileName, dynamic data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("写入缓存失败: $e");
    }
  }

  Future<dynamic> _loadFromFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        return jsonDecode(await file.readAsString());
      }
    } catch (e) {
      debugPrint("读取缓存文件失败: $e");
    }
    return null;
  }
}
