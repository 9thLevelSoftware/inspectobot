import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/domain/tenant_context.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';

import 'sync_outbox_store.dart';
import 'sync_runner.dart';

class SyncScheduler with WidgetsBindingObserver {
  SyncScheduler({
    required SyncRunner runner,
    Stream<Object>? connectivityChanges,
    Future<TenantContext?> Function()? activeTenantContextProvider,
  }) : _runner = runner,
       _connectivityChanges = connectivityChanges,
       _activeTenantContextProvider =
           activeTenantContextProvider ?? (() async => null);

  factory SyncScheduler.live() {
    if (!SupabaseClientProvider.isConfigured) {
      throw StateError(
        'Supabase must be configured before starting sync scheduler.',
      );
    }
    final runner = SyncRunner(
      outboxStore: SyncOutboxStore(),
      inspectionRemoteStore: SupabaseInspectionStore(
        SupabaseClientProvider.client,
      ),
      mediaRemoteStore: MediaSyncRemoteStore.live(),
    );
    final authRepository = AuthRepository.live();
    return SyncScheduler(
      runner: runner,
      connectivityChanges: Connectivity().onConnectivityChanged.map<Object>(
        (event) => event,
      ),
      activeTenantContextProvider: () async {
        final session = await authRepository.resolveCurrentSession();
        return session?.tenantContext;
      },
    );
  }

  static SyncScheduler? _instance;

  static SyncScheduler get instance => _instance ??= SyncScheduler.live();

  static void setInstanceForTest(SyncScheduler scheduler) {
    _instance = scheduler;
  }

  final SyncRunner _runner;
  final Stream<Object>? _connectivityChanges;
  final Future<TenantContext?> Function() _activeTenantContextProvider;
  StreamSubscription<Object>? _connectivitySubscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);

    if (_connectivityChanges != null) {
      _connectivitySubscription = _connectivityChanges.listen((event) {
        if (_isConnected(event)) {
          unawaited(runPending());
        }
      });
    }

    await runPending();
  }

  Future<void> stop() async {
    if (!_started) {
      return;
    }
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<SyncRunResult> runPending() async {
    final activeTenantContext = await _activeTenantContextProvider();
    return _runner.runPending(activeTenantContext: activeTenantContext);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(runPending());
    }
  }
}

bool _isConnected(Object event) {
  if (event is ConnectivityResult) {
    return event != ConnectivityResult.none;
  }
  if (event is List<ConnectivityResult>) {
    return event.any((result) => result != ConnectivityResult.none);
  }
  return false;
}
