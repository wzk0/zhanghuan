import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Select extends StatefulWidget {
  const Select({super.key});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final controller = _webViewController;
        if (controller != null && await controller.canGoBack()) {
          await controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('选课系统', style: TextStyle(fontSize: 16)),
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
                  ),
                )
              : null,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              "https://eams.tjzhic.edu.cn/student/for-std/course-select",
            ),
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
