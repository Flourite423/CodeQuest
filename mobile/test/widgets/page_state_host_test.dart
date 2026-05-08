import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:learning_app_mobile/controllers/base_controller.dart';
import 'package:learning_app_mobile/widgets/page_state_host.dart';

void main() {
  Widget buildHost(PageState state, {VoidCallback? onRetry}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: PageStateHost(
                state: state,
                message: 'State message',
                onRetry: onRetry,
                child: const Center(child: Text('Loaded content')),
              ),
            ),
          ),
        );
      },
    );
  }

  testWidgets('loading state renders shared loading widget', (tester) async {
    await tester.pumpWidget(buildHost(PageState.loading));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('State message'), findsOneWidget);
  });

  testWidgets('empty state renders reusable empty widget', (tester) async {
    await tester.pumpWidget(buildHost(PageState.empty));

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('State message'), findsOneWidget);
  });

  testWidgets('error state triggers retry callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildHost(PageState.error, onRetry: () => tapped = true),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('empty state shows refresh CTA when retry is available', (
    tester,
  ) async {
    await tester.pumpWidget(buildHost(PageState.empty, onRetry: () {}));

    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('offline state renders retry affordance', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildHost(PageState.offline, onRetry: () => tapped = true),
    );

    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('auth expired state shows session copy', (tester) async {
    await tester.pumpWidget(buildHost(PageState.authExpired));

    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('State message'), findsOneWidget);
    expect(find.text('Go to login'), findsNothing);
  });

  testWidgets('auth expired state triggers explicit login CTA when provided', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      buildHost(PageState.authExpired, onRetry: () => tapped = true),
    );

    expect(find.text('Go to login'), findsOneWidget);
    await tester.tap(find.text('Go to login'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('partial data state keeps content visible', (tester) async {
    await tester.pumpWidget(buildHost(PageState.partialData));

    expect(find.text('State message'), findsOneWidget);
    expect(find.text('Loaded content'), findsOneWidget);
  });

  testWidgets('partial data state triggers retry when CTA is tapped', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      buildHost(PageState.partialData, onRetry: () => tapped = true),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('initial state renders child directly', (tester) async {
    await tester.pumpWidget(buildHost(PageState.initial));

    expect(find.text('Loaded content'), findsOneWidget);
  });
}
