import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inspectobot/features/auth/domain/tenant_context.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_runner.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';

class _MockSyncRunner extends Mock implements SyncRunner {}

void main() {
  group('SyncScheduler', () {
    late _MockSyncRunner mockRunner;
    late StreamController<Object> connectivityController;
    late SyncScheduler scheduler;
    late TenantContext testTenantContext;

    setUp(() {
      mockRunner = _MockSyncRunner();
      connectivityController = StreamController<Object>.broadcast();
      testTenantContext = const TenantContext(
        userId: 'user-123',
        organizationId: 'org-123',
      );

      scheduler = SyncScheduler(
        runner: mockRunner,
        connectivityChanges: connectivityController.stream,
        activeTenantContextProvider: () async => testTenantContext,
      );
    });

    tearDown(() async {
      await scheduler.stop();
      await connectivityController.close();
    });

    group('start()', () {
      test('should call runPending on start', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should not start multiple times', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        await scheduler.start();
        await scheduler.start();

        // Should only be called once despite multiple start() calls
        verify(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext'))).called(1);
      });

      test('should register as WidgetsBindingObserver', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();

        // The scheduler should be registered as an observer
        expect(WidgetsBinding.instance.observers.contains(scheduler), isTrue);
      });
    });

    group('stop()', () {
      test('should cancel connectivity subscription on stop', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        await scheduler.stop();

        // After stopping, adding to connectivity stream should not trigger runPending
        clearInteractions(mockRunner);
        connectivityController.add(ConnectivityResult.wifi);
        await Future.delayed(Duration.zero);

        verifyNever(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')));
      });

      test('should remove WidgetsBindingObserver on stop', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        await scheduler.stop();

        expect(WidgetsBinding.instance.observers.contains(scheduler), isFalse);
      });

      test('should be safe to call stop when not started', () async {
        await expectLater(scheduler.stop(), completes);
      });

      test('should be safe to call stop multiple times', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        await scheduler.stop();
        await scheduler.stop();
        await scheduler.stop();

        // Should not throw
        expect(true, isTrue);
      });
    });

    group('connectivity change triggers', () {
      test('should trigger sync when connectivity changes to wifi', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();

        // Clear the initial call
        clearInteractions(mockRunner);

        connectivityController.add(ConnectivityResult.wifi);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should trigger sync when connectivity changes to mobile', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        connectivityController.add(ConnectivityResult.mobile);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should not trigger sync when connectivity changes to none', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        connectivityController.add(ConnectivityResult.none);
        await Future.delayed(Duration.zero);

        verifyNever(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')));
      });

      test('should handle list of connectivity results', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        // Some platforms return a list of connectivity results
        connectivityController.add([ConnectivityResult.wifi, ConnectivityResult.mobile]);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should not trigger sync when all results in list are none', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        connectivityController.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);

        verifyNever(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')));
      });

      test('should trigger sync when at least one result in list is connected', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        connectivityController.add([ConnectivityResult.none, ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });
    });

    group('app lifecycle integration', () {
      test('should trigger sync when app resumes', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        // Simulate app resume
        scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should not trigger sync on other lifecycle states', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        // These should not trigger sync
        scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
        scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);
        scheduler.didChangeAppLifecycleState(AppLifecycleState.detached);
        scheduler.didChangeAppLifecycleState(AppLifecycleState.hidden);
        await Future.delayed(Duration.zero);

        verifyNever(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')));
      });
    });

    group('runPending()', () {
      test('should call runner with active tenant context', () async {
        when(() => mockRunner.runPending(activeTenantContext: testTenantContext))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 5,
                  succeeded: 5,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        final result = await scheduler.runPending();

        expect(result.attempted, 5);
        expect(result.succeeded, 5);
        expect(result.failed, 0);
        expect(result.skipped, 0);
      });

      test('should handle null tenant context', () async {
        final schedulerWithoutTenant = SyncScheduler(
          runner: mockRunner,
          connectivityChanges: connectivityController.stream,
          activeTenantContextProvider: () async => null,
        );

        when(() => mockRunner.runPending(activeTenantContext: null))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await schedulerWithoutTenant.start();
        final result = await schedulerWithoutTenant.runPending();

        expect(result.attempted, 0);
        await schedulerWithoutTenant.stop();
      });

      test('should pass correct tenant context to runner', () async {
        final customTenantContext = const TenantContext(
          userId: 'custom-user',
          organizationId: 'custom-org',
        );

        final customScheduler = SyncScheduler(
          runner: mockRunner,
          connectivityChanges: null,
          activeTenantContextProvider: () async => customTenantContext,
        );

        when(() => mockRunner.runPending(activeTenantContext: customTenantContext))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 0,
                  succeeded: 0,
                  failed: 0,
                  skipped: 0,
                ));

        await customScheduler.start();

        verify(() => mockRunner.runPending(activeTenantContext: customTenantContext)).called(1);
        await customScheduler.stop();
      });
    });

    group('singleton instance', () {
      test('should set instance for testing', () {
        final testScheduler = SyncScheduler(
          runner: mockRunner,
          connectivityChanges: null,
          activeTenantContextProvider: () async => null,
        );

        SyncScheduler.setInstanceForTest(testScheduler);

        expect(SyncScheduler.instance, testScheduler);
      });
    });

    group('drains sync outbox on trigger', () {
      test('should drain outbox when connectivity changes', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 1,
                  succeeded: 1,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        connectivityController.add(ConnectivityResult.wifi);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should drain outbox on app resume', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 3,
                  succeeded: 3,
                  failed: 0,
                  skipped: 0,
                ));

        await scheduler.start();
        clearInteractions(mockRunner);

        scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(Duration.zero);

        verify(() => mockRunner.runPending(activeTenantContext: testTenantContext)).called(1);
      });

      test('should report sync results accurately', () async {
        when(() => mockRunner.runPending(activeTenantContext: any(named: 'activeTenantContext')))
            .thenAnswer((_) async => SyncRunResult(
                  attempted: 10,
                  succeeded: 7,
                  failed: 2,
                  skipped: 1,
                ));

        await scheduler.start();
        final result = await scheduler.runPending();

        expect(result.attempted, 10);
        expect(result.succeeded, 7);
        expect(result.failed, 2);
        expect(result.skipped, 1);
      });
    });
  });
}
