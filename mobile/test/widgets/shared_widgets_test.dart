import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codequest/widgets/shared/app_header.dart';
import 'package:codequest/widgets/shared/bottom_sheet_scaffold.dart';
import 'package:codequest/widgets/shared/cta_bar.dart';
import 'package:codequest/widgets/shared/empty_state.dart';
import 'package:codequest/widgets/shared/error_state.dart';
import 'package:codequest/widgets/shared/list_card.dart';
import 'package:codequest/widgets/shared/loading_state.dart';
import 'package:codequest/widgets/shared/rank_row.dart';

Widget buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    },
  );
}

void _dummyRetry() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmptyState', () {
    testWidgets('renders icon, title, description and CTA button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          description: 'Content will appear when available.',
          actionLabel: 'Refresh',
          onAction: null,
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Content will appear when available.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('renders without CTA button when actionLabel is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          description: 'Content will appear when available.',
        ),
      ));

      expect(find.text('Refresh'), findsNothing);
    });

    testWidgets('triggers onAction when CTA button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          description: 'Content will appear when available.',
          actionLabel: 'Refresh',
          onAction: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('ErrorState', () {
    testWidgets('renders error icon, title, message and retry button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const ErrorState(
          message: 'Network error occurred.',
          onRetry: _dummyRetry,
        ),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('出了点问题'), findsOneWidget);
      expect(find.text('Network error occurred.'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('triggers onRetry when retry button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        ErrorState(
          message: 'Network error occurred.',
          onRetry: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('重试'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('LoadingState', () {
    testWidgets('renders progress indicator and message when provided', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const LoadingState(message: 'Loading data...'),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('renders only progress indicator when no message', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const LoadingState(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // No text should be rendered aside from Material defaults
      expect(find.text('Loading data...'), findsNothing);
    });
  });

  group('CTABar', () {
    testWidgets('renders primary button only when no secondary', (tester) async {
      await tester.pumpWidget(buildTestApp(
        CTABar(
          primaryLabel: 'Continue',
          onPrimary: () {},
        ),
      ));

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('triggers primary and secondary callbacks when tapped', (
      tester,
    ) async {
      var primaryTapped = false;
      var secondaryTapped = false;

      await tester.pumpWidget(buildTestApp(
        CTABar(
          primaryLabel: 'Save',
          onPrimary: () => primaryTapped = true,
          secondaryLabel: 'Cancel',
          onSecondary: () => secondaryTapped = true,
        ),
      ));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(primaryTapped, isTrue);
      expect(secondaryTapped, isTrue);
    });

    testWidgets('renders both primary and secondary buttons', (tester) async {
      await tester.pumpWidget(buildTestApp(
        CTABar(
          primaryLabel: 'Submit',
          onPrimary: () {},
          secondaryLabel: 'Cancel',
          onSecondary: () {},
        ),
      ));

      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('AppHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const AppHeader(title: 'Dashboard'),
      ));

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders back button when showBackButton is true', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const AppHeader(
          title: 'Dashboard',
          showBackButton: true,
        ),
      ));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('invokes custom back callback when back button is tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(buildTestApp(
        AppHeader(
          title: 'Dashboard',
          showBackButton: true,
          onBack: () => tapped = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const AppHeader(
          title: 'Dashboard',
          subtitle: 'Your learning progress',
        ),
      ));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Your learning progress'), findsOneWidget);
    });

    testWidgets('renders action buttons when provided', (tester) async {
      await tester.pumpWidget(buildTestApp(
        AppHeader(
          title: 'Dashboard',
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('ListCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const ListCard(title: 'Course Title'),
      ));

      expect(find.text('Course Title'), findsOneWidget);
    });

    testWidgets('renders leading, subtitle, trailing and handles tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        ListCard(
          leading: const Icon(Icons.book),
          title: 'Course Title',
          subtitle: 'Course summary',
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => tapped = true,
        ),
      ));

      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.text('Course Title'), findsOneWidget);
      expect(find.text('Course summary'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      await tester.tap(find.text('Course Title'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('RankRow', () {
    testWidgets('rank 1 shows gold trophy icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 1,
          username: 'Alice',
          level: 10,
          xp: 5000,
        ),
      ));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Level 10'), findsOneWidget);
      expect(find.text('5000 XP'), findsOneWidget);
    });

    testWidgets('rank 2 shows silver trophy icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 2,
          username: 'Bob',
          level: 8,
          xp: 3200,
        ),
      ));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('rank 3 shows bronze trophy icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 3,
          username: 'Charlie',
          level: 6,
          xp: 2100,
        ),
      ));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('rank 4+ shows rank number instead of trophy', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 4,
          username: 'Dave',
          level: 5,
          xp: 1500,
        ),
      ));

      expect(find.byIcon(Icons.emoji_events), findsNothing);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);
    });

    testWidgets('highlights current user with distinct background', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 5,
          username: 'Eve',
          level: 3,
          xp: 800,
          isCurrentUser: true,
        ),
      ));

      expect(find.text('Eve'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('800 XP'), findsOneWidget);
    });

    testWidgets('shows initial letter avatar when avatarUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(
        const RankRow(
          rank: 1,
          username: 'Alice',
          level: 10,
          xp: 5000,
        ),
      ));

      // CircleAvatar with no NetworkImage uses initial letter
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('invokes onTap when row is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestApp(
        RankRow(
          rank: 6,
          username: 'Frank',
          level: 2,
          xp: 600,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Frank'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('BottomSheetScaffold', () {
    testWidgets('renders drag handle, title, content and actions', (
      tester,
    ) async {
      var primaryTapped = false;
      var secondaryTapped = false;

      await tester.pumpWidget(buildTestApp(
        BottomSheetScaffold(
          title: 'Sheet title',
          content: const Text('Sheet content'),
          actions: [
            FilledButton(
              onPressed: () => primaryTapped = true,
              child: const Text('Confirm'),
            ),
            OutlinedButton(
              onPressed: () => secondaryTapped = true,
              child: const Text('Later'),
            ),
          ],
        ),
      ));

      expect(find.text('Sheet title'), findsOneWidget);
      expect(find.text('Sheet content'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.tap(find.text('Later'));
      await tester.pump();

      expect(primaryTapped, isTrue);
      expect(secondaryTapped, isTrue);
    });

    testWidgets('can hide drag handle and title section', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const BottomSheetScaffold(
          showDragHandle: false,
          content: Text('Content only'),
        ),
      ));

      expect(find.text('Content only'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}
