import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../features/audit/data/audit_event_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/tenant_context_resolver.dart';
import '../features/delivery/data/delivery_repository.dart';
import '../features/identity/data/inspector_profile_repository.dart';
import '../features/identity/data/signature_repository.dart';
import '../features/inspection/data/inspection_repository.dart';
import '../features/media/local_media_store.dart';
import '../features/media/media_capture_service.dart';
import '../features/media/media_sync_remote_store.dart';
import '../features/pdf/cloud_pdf_service.dart';
import '../features/pdf/narrative/narrative_media_resolver.dart';
import '../features/pdf/narrative/narrative_print_theme.dart';
import '../features/pdf/narrative/narrative_report_engine.dart';
import '../features/pdf/narrative/narrative_template_registry.dart';
import '../features/pdf/narrative/templates/general_inspection_template.dart';
import '../features/pdf/narrative/templates/mold_assessment_template.dart';
import '../features/pdf/on_device_pdf_service.dart';
import '../features/pdf/pdf_orchestrator.dart';
import '../features/pdf/data/pdf_size_budget_config_store.dart';
import '../features/sync/sync_outbox_store.dart';
import '../features/sync/sync_scheduler.dart';
import 'auth_notifier.dart';
import 'navigation_service.dart';
import 'router_config.dart';

/// Production service locator setup.
///
/// Call this once during app startup, before [runApp].
/// Registers all required singletons in dependency order.
Future<void> setupServiceLocator(AuthRepository authRepository) async {
  final getIt = GetIt.I;

  // AuthNotifier — singleton, owns the auth state lifecycle
  final authNotifier = AuthNotifier(authRepository);
  getIt.registerSingleton<AuthNotifier>(authNotifier);

  // GoRouter — singleton, depends on AuthNotifier
  final router = createRouter(authNotifier);
  getIt.registerSingleton<GoRouter>(router);

  // NavigationService — singleton, wraps GoRouter
  getIt.registerSingleton<NavigationService>(
    GoRouterNavigationService(router),
  );

  // TenantContextResolver — singleton for organization/user resolution
  getIt.registerSingleton<TenantContextResolver>(TenantContextResolver.live());

  // AuditEventRepository — singleton for audit logging
  getIt.registerSingleton<AuditEventRepository>(AuditEventRepository.live());

  // SyncOutboxStore — singleton for pending sync operations
  getIt.registerSingleton<SyncOutboxStore>(SyncOutboxStore());

  // SyncScheduler — singleton, auto-starts on app init
  getIt.registerSingleton<SyncScheduler>(SyncScheduler.instance);

  // LocalMediaStore — singleton for local media manifests
  getIt.registerSingleton<LocalMediaStore>(LocalMediaStore());

  // MediaCaptureService — singleton for photo/document capture
  getIt.registerSingleton<MediaCaptureService>(MediaCaptureService());

  // MediaSyncRemoteStore — singleton for remote media sync
  // Requires Supabase to be configured
  if (authRepository.currentSession != null) {
    getIt.registerSingleton<MediaSyncRemoteStore>(
      MediaSyncRemoteStore.live(),
    );
  }

  // InspectionRepository — singleton with offline-first storage
  getIt.registerSingleton<InspectionRepository>(
    InspectionRepository.live(),
  );

  // PDF Services — singletons for PDF generation pipeline
  getIt.registerSingleton<OnDevicePdfService>(OnDevicePdfService());
  getIt.registerSingleton<CloudPdfService>(const CloudPdfService());
  getIt.registerSingleton<PdfSizeBudgetConfigStore>(PdfSizeBudgetConfigStore());

  // NarrativeReportEngine — singleton for narrative PDF generation
  final generalTemplate = const GeneralInspectionTemplate();
  final moldTemplate = const MoldAssessmentTemplate();
  getIt.registerSingleton<NarrativeReportEngine>(
    NarrativeReportEngine(
      registry: NarrativeTemplateRegistry(
        templates: {
          generalTemplate.formType: generalTemplate,
          moldTemplate.formType: moldTemplate,
        },
      ),
      mediaResolver: const NarrativeMediaResolver(),
      theme: NarrativePrintTheme.standard(),
    ),
  );

  // PdfOrchestrator — singleton that coordinates PDF generation
  getIt.registerSingleton<PdfOrchestrator>(
    PdfOrchestrator(
      onDevice: getIt<OnDevicePdfService>(),
      cloud: getIt<CloudPdfService>(),
      narrative: getIt<NarrativeReportEngine>(),
      sizeBudgetStore: getIt<PdfSizeBudgetConfigStore>(),
    ),
  );

  // Identity Repositories — singletons for inspector profile/signature
  getIt.registerSingleton<InspectorProfileRepository>(
    InspectorProfileRepository.live(),
  );
  getIt.registerSingleton<SignatureRepository>(SignatureRepository.live());

  // DeliveryRepository — singleton for report delivery actions
  getIt.registerSingleton<DeliveryRepository>(DeliveryRepository.live());
}

/// Reset the service locator. Call in [tearDown] during tests.
@visibleForTesting
Future<void> resetServiceLocator() async {
  await GetIt.I.reset();
}

/// Test-only service locator setup with optional mock overrides.
///
/// Registers provided mocks or creates minimal defaults.
/// Always call [resetServiceLocator] in tearDown.
@visibleForTesting
void setupTestServiceLocator({
  AuthNotifier? authNotifier,
  NavigationService? navigationService,
  GoRouter? router,
  InspectionRepository? inspectionRepository,
  LocalMediaStore? localMediaStore,
  MediaCaptureService? mediaCaptureService,
  SyncOutboxStore? syncOutboxStore,
  SyncScheduler? syncScheduler,
  PdfOrchestrator? pdfOrchestrator,
  OnDevicePdfService? onDevicePdfService,
  CloudPdfService? cloudPdfService,
  NarrativeReportEngine? narrativeReportEngine,
  PdfSizeBudgetConfigStore? pdfSizeBudgetConfigStore,
  TenantContextResolver? tenantContextResolver,
  AuditEventRepository? auditEventRepository,
  InspectorProfileRepository? inspectorProfileRepository,
  SignatureRepository? signatureRepository,
  DeliveryRepository? deliveryRepository,
}) {
  final getIt = GetIt.I;

  if (authNotifier != null) {
    getIt.registerSingleton<AuthNotifier>(authNotifier);
  }

  if (router != null) {
    getIt.registerSingleton<GoRouter>(router);
  }

  if (navigationService != null) {
    getIt.registerSingleton<NavigationService>(navigationService);
  }

  if (tenantContextResolver != null) {
    getIt.registerSingleton<TenantContextResolver>(tenantContextResolver);
  }

  if (auditEventRepository != null) {
    getIt.registerSingleton<AuditEventRepository>(auditEventRepository);
  }

  if (syncOutboxStore != null) {
    getIt.registerSingleton<SyncOutboxStore>(syncOutboxStore);
  }

  if (syncScheduler != null) {
    getIt.registerSingleton<SyncScheduler>(syncScheduler);
  }

  if (localMediaStore != null) {
    getIt.registerSingleton<LocalMediaStore>(localMediaStore);
  }

  if (mediaCaptureService != null) {
    getIt.registerSingleton<MediaCaptureService>(mediaCaptureService);
  }

  if (inspectionRepository != null) {
    getIt.registerSingleton<InspectionRepository>(inspectionRepository);
  }

  if (onDevicePdfService != null) {
    getIt.registerSingleton<OnDevicePdfService>(onDevicePdfService);
  }

  if (cloudPdfService != null) {
    getIt.registerSingleton<CloudPdfService>(cloudPdfService);
  }

  if (pdfSizeBudgetConfigStore != null) {
    getIt.registerSingleton<PdfSizeBudgetConfigStore>(pdfSizeBudgetConfigStore);
  }

  if (narrativeReportEngine != null) {
    getIt.registerSingleton<NarrativeReportEngine>(narrativeReportEngine);
  }

  if (pdfOrchestrator != null) {
    getIt.registerSingleton<PdfOrchestrator>(pdfOrchestrator);
  }

  if (inspectorProfileRepository != null) {
    getIt.registerSingleton<InspectorProfileRepository>(inspectorProfileRepository);
  }

  if (signatureRepository != null) {
    getIt.registerSingleton<SignatureRepository>(signatureRepository);
  }

  if (deliveryRepository != null) {
    getIt.registerSingleton<DeliveryRepository>(deliveryRepository);
  }
}
