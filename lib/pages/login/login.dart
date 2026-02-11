import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String _loginUrl = 'https://eams.tjzhic.edu.cn/student/login';
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录教务系统', style: TextStyle(fontSize: 16)),
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress, minHeight: 3),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_loginUrl)),
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
        onLoadStart: (controller, url) async {
          if (url != null) {
            _checkLoginSuccess(url);
          }
        },
      ),
    );
  }

  Future<void> _checkLoginSuccess(WebUri url) async {
    if (url.toString().contains('/home')) {
      final success = await AuthService.captureAndSaveCookies(url);
      if (success && mounted) {
        Fluttertoast.showToast(msg: '登录成功! 如需更新登录状态, 请点击右上角刷新按钮');
        Navigator.pop(context, true);
      }
    }
  }
}
