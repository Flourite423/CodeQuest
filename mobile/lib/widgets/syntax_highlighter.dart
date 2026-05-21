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
    // Pre-compute all highlighted spans, tracking multi-line comment state
    final spans = <TextSpan>[];
    bool inMultiLineComment = false;
    for (final line in lines) {
      final result = _highlightLineWithState(line, theme, inMultiLineComment);
      spans.add(result.span);
      inMultiLineComment = result.inComment;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (i) {
        return _buildLine(i, lines[i], spans[i], theme);
      }),
    );
  }

  Widget _buildLine(int lineIndex, String line, TextSpan span, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              '${lineIndex + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: span,
            ),
          ),
        ],
      ),
    );
  }

  /// Result of highlighting a single line, carrying forward comment state.
  static _LineHighlightResult _highlightLineWithState(
      String line, ThemeData theme, bool inMultiLineComment) {
    final commentStyle = TextStyle(
      color: Colors.grey,
      fontFamily: 'monospace',
      fontSize: 14.sp,
      fontStyle: FontStyle.italic,
    );

    // If we are inside a multi-line comment from a previous line,
    // check whether this line closes it.
    if (inMultiLineComment) {
      final closeIndex = line.indexOf('-->');
      if (closeIndex == -1) {
        // Whole line is still inside the comment
        return _LineHighlightResult(
          span: TextSpan(text: line, style: commentStyle),
          inComment: true,
        );
      }
      // Comment ends partway through this line
      final afterClose = closeIndex + 3;
      final commentPart = line.substring(0, afterClose);
      final rest = line.substring(afterClose);
      if (rest.isEmpty) {
        return _LineHighlightResult(
          span: TextSpan(text: line, style: commentStyle),
          inComment: false,
        );
      }
      return _LineHighlightResult(
        span: TextSpan(children: [
          TextSpan(text: commentPart, style: commentStyle),
          ..._highlightCodeSegment(rest, theme),
        ]),
        inComment: false,
      );
    }

    // Check for CSS-only single-line comments: // or /* ... */
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//')) {
      return _LineHighlightResult(
        span: TextSpan(text: line, style: commentStyle),
        inComment: false,
      );
    }
    if (trimmed.startsWith('/*') && trimmed.endsWith('*/')) {
      return _LineHighlightResult(
        span: TextSpan(text: line, style: commentStyle),
        inComment: false,
      );
    }

    // Check for HTML comment start: <!--
    final htmlCommentStart = line.indexOf('<!--');
    if (htmlCommentStart != -1) {
      final htmlCommentEnd = line.indexOf('-->', htmlCommentStart + 4);
      if (htmlCommentEnd != -1) {
        // Single-line HTML comment embedded in code
        final before = line.substring(0, htmlCommentStart);
        final commentText = line.substring(htmlCommentStart, htmlCommentEnd + 3);
        final after = line.substring(htmlCommentEnd + 3);
        return _LineHighlightResult(
          span: TextSpan(children: [
            if (before.isNotEmpty) ..._highlightCodeSegment(before, theme),
            TextSpan(text: commentText, style: commentStyle),
            if (after.isNotEmpty) ..._highlightCodeSegment(after, theme),
          ]),
          inComment: false,
        );
      } else {
        // Multi-line comment starts here but doesn't close
        final before = line.substring(0, htmlCommentStart);
        final commentText = line.substring(htmlCommentStart);
        return _LineHighlightResult(
          span: TextSpan(children: [
            if (before.isNotEmpty) ..._highlightCodeSegment(before, theme),
            TextSpan(text: commentText, style: commentStyle),
          ]),
          inComment: true,
        );
      }
    }

    // Not a comment line – apply normal syntax highlighting
    return _LineHighlightResult(
      span: TextSpan(children: _highlightCodeSegment(line, theme)),
      inComment: false,
    );
  }

  /// Highlights a code segment that is NOT inside a comment.
  static List<TextSpan> _highlightCodeSegment(String segment, ThemeData theme) {
    final children = <TextSpan>[];
    final buffer = StringBuffer();
    bool inTag = false;
    bool inAttribute = false;
    bool inString = false;
    String stringChar = '';

    void flushBuffer(Color color, {bool bold = false}) {
      if (buffer.isEmpty) return;
      children.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: 14.sp,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ));
      buffer.clear();
    }

    for (int i = 0; i < segment.length; i++) {
      final char = segment[i];

      if (inString) {
        buffer.write(char);
        if (char == stringChar) {
          inString = false;
          flushBuffer(Colors.green);
        }
        continue;
      }

      if (char == '"' || char == "'") {
        flushBuffer(_getColorForContext(inTag, inAttribute, theme));
        inString = true;
        stringChar = char;
        buffer.write(char);
        continue;
      }

      if (char == '<') {
        flushBuffer(theme.colorScheme.onSurface);
        inTag = true;
        buffer.write(char);
        continue;
      }

      if (char == '>') {
        buffer.write(char);
        flushBuffer(Colors.blue, bold: true);
        inTag = false;
        inAttribute = false;
        continue;
      }

      if (inTag && char == ' ') {
        flushBuffer(Colors.blue, bold: true);
        inAttribute = true;
        buffer.write(char);
        continue;
      }

      if (inTag && char == '=') {
        flushBuffer(Colors.orange);
        buffer.write(char);
        continue;
      }

      // CSS property detection: property-name: value;
      if (!inTag && char == ':') {
        final propCandidate = buffer.toString().trimLeft();
        final cssPropRegExp = RegExp(r'^[a-z][a-z0-9-]*$');
        if (cssPropRegExp.hasMatch(propCandidate)) {
          flushBuffer(theme.colorScheme.onSurface);
          children.add(TextSpan(
            text: ':',
            style: TextStyle(
              color: Colors.green,
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          // Read until semicolon or end for the value
          final valueStart = i + 1;
          var valueEnd = segment.indexOf(';', valueStart);
          if (valueEnd == -1) valueEnd = segment.length;
          final value = segment.substring(valueStart, valueEnd);
          children.add(TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.orange,
              fontFamily: 'monospace',
              fontSize: 14.sp,
            ),
          ));
          i = valueEnd - 1; // skip ahead (loop will i++)
          buffer.clear();
          continue;
        }
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      flushBuffer(_getColorForContext(inTag, inAttribute, theme));
    }

    return children;
  }

  static Color _getColorForContext(bool inTag, bool inAttribute, ThemeData theme) {
    if (inTag) {
      return Colors.blue;
    }
    if (inAttribute) {
      return Colors.orange;
    }
    return theme.colorScheme.onSurface;
  }
}

/// Helper to carry forward multi-line comment state across line processing.
class _LineHighlightResult {
  const _LineHighlightResult({required this.span, required this.inComment});
  final TextSpan span;
  final bool inComment;
}
