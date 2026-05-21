import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SyntaxHighlighter extends StatelessWidget {
  const SyntaxHighlighter({
    super.key,
    required this.code,
    this.language = 'html',
  });

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '语法高亮预览',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildHighlightedCode(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedCode(ThemeData theme) {
    final lines = code.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line, theme)).toList(),
    );
  }

  Widget _buildLine(String line, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: _highlightLine(line, theme),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _highlightLine(String line, ThemeData theme) {
    final children = <TextSpan>[];
    final buffer = StringBuffer();
    bool inTag = false;
    bool inAttribute = false;
    bool inString = false;
    String stringChar = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (inString) {
        buffer.write(char);
        if (char == stringChar) {
          inString = false;
          children.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              color: Colors.green,
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          buffer.clear();
        }
        continue;
      }

      if (char == '"' || char == "'") {
        if (buffer.isNotEmpty) {
          children.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              color: _getColorForContext(inTag, inAttribute, theme),
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          buffer.clear();
        }
        inString = true;
        stringChar = char;
        buffer.write(char);
        continue;
      }

      if (char == '<') {
        if (buffer.isNotEmpty) {
          children.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          buffer.clear();
        }
        inTag = true;
        buffer.write(char);
        continue;
      }

      if (char == '>') {
        buffer.write(char);
        children.add(TextSpan(
          text: buffer.toString(),
          style: TextStyle(
            color: Colors.blue,
            fontFamily: 'monospace',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ));
        buffer.clear();
        inTag = false;
        inAttribute = false;
        continue;
      }

      if (inTag && char == ' ') {
        if (buffer.isNotEmpty) {
          children.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              color: Colors.blue,
              fontFamily: 'monospace',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ));
          buffer.clear();
        }
        inAttribute = true;
        buffer.write(char);
        continue;
      }

      if (inTag && char == '=') {
        if (buffer.isNotEmpty) {
          children.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              color: Colors.orange,
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          buffer.clear();
        }
        buffer.write(char);
        continue;
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      children.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(
          color: _getColorForContext(inTag, inAttribute, theme),
          fontFamily: 'monospace',
          fontSize: 14.sp,
        ),
      ));
    }

    return TextSpan(children: children);
  }

  Color _getColorForContext(bool inTag, bool inAttribute, ThemeData theme) {
    if (inTag) {
      return Colors.blue;
    }
    if (inAttribute) {
      return Colors.orange;
    }
    return theme.colorScheme.onSurface;
  }
}
