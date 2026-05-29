import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Unified syntax highlighter widget supporting multiple languages.
/// 
/// Uses flutter_highlight package for robust syntax highlighting.
/// Supports: html, css, javascript, python, dart, and more.
class SyntaxHighlighter extends StatelessWidget {
  const SyntaxHighlighter({
    super.key,
    required this.code,
    this.language = 'html',
    this.showLineNumbers = true,
    this.isDark = false,
  });

  final String code;
  final String language;
  final bool showLineNumbers;
  final bool isDark;

  /// Language mapping for common aliases
  static const Map<String, String> _languageMap = {
    'html': 'html',
    'css': 'css',
    'js': 'javascript',
    'javascript': 'javascript',
    'python': 'python',
    'py': 'python',
    'dart': 'dart',
    'java': 'java',
    'cpp': 'cpp',
    'c': 'c',
    'sql': 'sql',
    'json': 'json',
    'xml': 'xml',
    'bash': 'bash',
    'shell': 'bash',
    'yaml': 'yaml',
    'markdown': 'markdown',
    'md': 'markdown',
  };

  String get _normalizedLanguage {
    final normalized = language.toLowerCase().trim();
    return _languageMap[normalized] ?? normalized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final highlightTheme = isDark ? atomOneDarkTheme : githubTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF282C34) 
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLineNumbers) ...[
                  _buildLineNumbers(context),
                  SizedBox(width: 16.w),
                ],
                HighlightView(
                  code,
                  language: _normalizedLanguage,
                  theme: highlightTheme,
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineNumbers(BuildContext context) {
    final lines = code.split('\n');
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(lines.length, (index) {
        return Text(
          '${index + 1}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontFamily: 'monospace',
            fontSize: 14.sp,
            height: 1.5,
          ),
        );
      }),
    );
  }
}

/// A read-only code display widget for showing highlighted code blocks.
/// Simpler version without line numbers for inline use.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.language = 'html',
  });

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: HighlightView(
            code,
            language: language.toLowerCase(),
            theme: githubTheme,
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
