import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CodePreviewWebView extends StatefulWidget {
  const CodePreviewWebView({
    super.key,
    required this.htmlCode,
  });

  final String htmlCode;

  @override
  State<CodePreviewWebView> createState() => _CodePreviewWebViewState();
}

class _CodePreviewWebViewState extends State<CodePreviewWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
    _loadHtmlContent();
  }

  @override
  void didUpdateWidget(CodePreviewWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlCode != widget.htmlCode) {
      _loadHtmlContent();
    }
  }

  void _loadHtmlContent() {
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
    }
  </style>
</head>
<body>
  ${widget.htmlCode}
</body>
</html>
''';
    _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
