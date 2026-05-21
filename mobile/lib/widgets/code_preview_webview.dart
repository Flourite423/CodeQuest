import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CodePreviewWebView extends StatefulWidget {
  const CodePreviewWebView({
    super.key,
    required this.htmlCode,
    this.cssCode = '',
  });

  final String htmlCode;
  final String cssCode;

  @override
  State<CodePreviewWebView> createState() => _CodePreviewWebViewState();
}

class _CodePreviewWebViewState extends State<CodePreviewWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _lastError;

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
              _lastError = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _lastError = error.description;
            });
          },
        ),
      );
    _loadHtmlContent();
  }

  @override
  void didUpdateWidget(CodePreviewWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlCode != widget.htmlCode ||
        oldWidget.cssCode != widget.cssCode) {
      _loadHtmlContent();
    }
  }

  void _loadHtmlContent() {
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'none'; object-src 'none'; style-src 'unsafe-inline';">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background-color: #ffffff;
      color: #333333;
    }
    ${widget.cssCode}
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
            if (_lastError != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '预览加载失败',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _lastError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
