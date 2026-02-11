import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Vocation extends StatefulWidget {
  const Vocation({super.key});

  @override
  State<Vocation> createState() => _VocationState();
}

class _VocationState extends State<Vocation> {
  final String loginUrl = 'http://work.tjzhic.edu.cn:7565/dormitory/index';
  InAppWebViewController? _webViewController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
      msg: '初始密码: tjzhic2015',
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final controller = _webViewController;
        if (controller != null && await controller.canGoBack()) {
          await controller.goBack();
        } else {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('请假系统', style: TextStyle(fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final controller = _webViewController;
              if (controller != null && await controller.canGoBack()) {
                await controller.goBack();
              } else {
                navigator.pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : null,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            useOnDownloadStart: true,
          ),
          onWebViewCreated: (controller) => _webViewController = controller,
          onProgressChanged: (controller, progress) {
            setState(() => _progress = progress / 100);
          },
        ),
      ),
    );
  }
}
