import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _cookieKey = 'cookies';

  static Future<bool> isLoggedIn() async {
    final cookies = await getSavedCookies();
    return cookies != null && cookies.isNotEmpty;
  }

  static Future<bool> captureAndSaveCookies(WebUri url) async {
    try {
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: url);

      if (cookies.isEmpty) return false;

      final cookieString = cookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_cookieKey, cookieString);
    } catch (e) {
      debugPrint("Cookie 捕获失败: $e");
      return false;
    }
  }

  static Future<String?> getSavedCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    await CookieManager.instance().deleteAllCookies();
  }
}
