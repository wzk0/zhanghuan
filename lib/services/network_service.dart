import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  Future<dynamic> request(
    String url, {
    bool isPost = false,
    Map<String, dynamic>? body,
    // 将必填改为可选，因为 POST 往往不需要 URL 参数
    Map<String, dynamic>? queryParameters,
  }) async {
    // 构造带 query 参数的 URI
    Uri uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final String? cookies = prefs.getString('cookies')?.replaceAll('"', '');

    final linkHash = md5
        .convert(utf8.encode(url + (body?.toString() ?? "")))
        .toString();
    final cacheFileName = 'cache-$linkHash.json';

    try {
      final headers = {
        'Cookie': cookies ?? '',
        'Accept': 'application/json, text/plain, */*',
      };

      http.Response response;
      if (isPost) {
        headers['Content-Type'] = 'application/json;charset=UTF-8';
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        await _saveToFile(cacheFileName, decoded);
        return decoded;
      } else {
        debugPrint("请求失败，状态码: ${response.statusCode}, 响应: ${response.body}");
      }
    } catch (e) {
      debugPrint("网络请求异常: $e");
    }
    return await _loadFromFile(cacheFileName);
  }

  Future<void> _saveToFile(String fileName, dynamic data) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> _loadFromFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      return jsonDecode(await file.readAsString());
    }
    return null;
  }
}
