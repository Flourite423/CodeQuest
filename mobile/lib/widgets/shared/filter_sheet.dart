import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'bottom_sheet_scaffold.dart';

/// A single selectable option within a [FilterSection].
class FilterOption {
  const FilterOption({
    required this.value,
    required this.label,
  });

  /// The raw value used for filtering logic.
  final String value;

  /// The human-readable label displayed on the chip.
  final String label;
}

/// A group of related filter options displayed as chips.
class FilterSection {
  const FilterSection({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.allowMultiple = true,
  });

  /// Section heading text.
  final String title;

  /// Available chip options in this section.
  final List<FilterOption> options;

  /// Currently selected values (populated before show).
  final Set<String> selectedValues;

  /// Called when the user presses Apply or Reset with the final selection.
  final ValueChanged<Set<String>> onChanged;

  /// Whether multiple chips can be selected simultaneously.
  /// When false, selecting a chip deselects all others in this section.
  final bool allowMultiple;
}

/// A reusable filter bottom sheet built on [BottomSheetScaffold].
///
/// Shows filter sections as chip groups with Apply and Reset actions.
/// Manages temporary local selection state until Apply is pressed.
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.title,
    required this.sections,
    required this.onApply,
    required this.onReset,
  });

  /// Sheet title shown in the drag-handle bar.
  final String title;

  /// Filter sections displayed as chip groups.
  final List<FilterSection> sections;

  /// Called after all section [FilterSection.onChanged] callbacks have
  /// been invoked. Use this to trigger a data reload or UI refresh.
  final VoidCallback onApply;

  /// Called when the user resets all filters.
  final VoidCallback onReset;

  /// Convenience method to show the filter sheet via [Get.bottomSheet].
  static Future<void> show({
    required String title,
    required List<FilterSection> sections,
    required VoidCallback onApply,
    required VoidCallback onReset,
  }) {
    return Get.bottomSheet(
      FilterSheet(
        title: title,
        sections: sections,
        onApply: onApply,
        onReset: onReset,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  /// Local mutable selections keyed by section title.
  late Map<String, Set<String>> _localSelections;

  @override
  void initState() {
    super.initState();
    _localSelections = {
      for (final section in widget.sections)
        section.title: Set<String>.from(section.selectedValues),
    };
  }

  void _toggleOption(String sectionTitle, String value, {required bool allowMultiple}) {
    setState(() {
      final current = _localSelections[sectionTitle] ?? <String>{};
      if (current.contains(value)) {
        current.remove(value);
      } else if (allowMultiple) {
        current.add(value);
      } else {
        current
          ..clear()
          ..add(value);
      }
    });
  }

  void _apply() {
    for (final section in widget.sections) {
      final selected = _localSelections[section.title] ?? <String>{};
      section.onChanged(selected);
    }
    widget.onApply();
    Get.back();
  }

  void _reset() {
    setState(() {
      for (final section in widget.sections) {
        _localSelections[section.title] = <String>{};
      }
    });
    for (final section in widget.sections) {
      section.onChanged(<String>{});
    }
    widget.onReset();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomSheetScaffold(
      title: widget.title,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.sections.map((section) {
          final selected = _localSelections[section.title] ?? <String>{};
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: section.options.map((option) {
                    final isSelected = selected.contains(option.value);
                    return FilterChip(
                      label: Text(option.label),
                      selected: isSelected,
                      onSelected: (_) => _toggleOption(
                        section.title,
                        option.value,
                        allowMultiple: section.allowMultiple,
                      ),
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      side: isSelected
                          ? BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            )
                          : BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton(
            onPressed: _apply,
            child: const Text('应用筛选'),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton(
            onPressed: _reset,
            child: const Text('重置筛选'),
          ),
        ),
      ],
    );
  }
}
