import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pdf_generation_input.dart';

class CloudPdfService {
  const CloudPdfService({
    this.runtimeGateway,
    this.functionName = 'generate-report-pdf',
  });

  final CloudPdfRuntimeGateway? runtimeGateway;
  final String functionName;

  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    final gateway = runtimeGateway;
    if (gateway != null) {
      return gateway.generate(input);
    }

    if (!SupabaseClientProvider.isConfigured) {
      return const CloudPdfGenerationOutcome.unavailable(
        reason: 'Cloud PDF generation is not configured.',
      );
    }

    final client = SupabaseClientProvider.client;
    final request = _buildCloudRequest(input);

    try {
      final response = await client.functions.invoke(functionName, body: request);
      final bytes = _extractPdfBytes(response.data);
      if (bytes == null || bytes.isEmpty) {
        return const CloudPdfGenerationOutcome.unavailable(
          reason: 'Cloud PDF response did not include artifact bytes.',
        );
      }
      final file = await _writeGeneratedFile(bytes);
      return CloudPdfGenerationOutcome.generated(file);
    } on FunctionException catch (error) {
      if (_isUnavailableStatus(error.status)) {
        return CloudPdfGenerationOutcome.unavailable(
          reason: 'Cloud PDF service unavailable (status: ${error.status}).',
        );
      }
      return CloudPdfGenerationOutcome.terminalFailure(
        error: error,
        reason: 'Cloud PDF generation failed (status: ${error.status}).',
      );
    } catch (error) {
      return CloudPdfGenerationOutcome.terminalFailure(
        error: error,
        reason: 'Cloud PDF generation failed unexpectedly.',
      );
    }
  }

  static Map<String, dynamic> _buildCloudRequest(PdfGenerationInput input) {
    return <String, dynamic>{
      'inspection_id': input.inspectionId,
      'organization_id': input.organizationId,
      'user_id': input.userId,
    };
  }

  static Uint8List? _extractPdfBytes(dynamic responseData) {
    if (responseData is Uint8List) {
      return responseData;
    }

    if (responseData is String) {
      final trimmed = responseData.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      try {
        return base64Decode(trimmed);
      } on FormatException {
        return null;
      }
    }

    if (responseData is! Map) {
      return null;
    }

    final payload = Map<String, dynamic>.from(responseData);
    final candidate = payload['pdf_base64'] ?? payload['pdfBase64'] ?? payload['pdf'];
    if (candidate is! String || candidate.trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(candidate.trim());
    } on FormatException {
      return null;
    }
  }

  static Future<File> _writeGeneratedFile(Uint8List bytes) async {
    final file = File(
      '${Directory.systemTemp.path}/inspectobot_cloud_${DateTime.now().microsecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static bool _isUnavailableStatus(int status) {
    return status == 404 || status == 429 || status == 503;
  }
}

abstract class CloudPdfRuntimeGateway {
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input);
}

class DisabledCloudPdfRuntimeGateway implements CloudPdfRuntimeGateway {
  const DisabledCloudPdfRuntimeGateway({this.reason});

  final String? reason;

  @override
  Future<CloudPdfGenerationOutcome> generate(PdfGenerationInput input) async {
    return CloudPdfGenerationOutcome.unavailable(
      reason: reason ?? 'Cloud PDF generation is not configured.',
    );
  }
}

enum CloudPdfGenerationOutcomeType {
  generated,
  unavailable,
  terminalFailure,
}

class CloudPdfGenerationOutcome {
  const CloudPdfGenerationOutcome._({
    required this.type,
    this.file,
    this.reason,
    this.error,
  });

  const CloudPdfGenerationOutcome.generated(File file)
    : this._(type: CloudPdfGenerationOutcomeType.generated, file: file);

  const CloudPdfGenerationOutcome.unavailable({String? reason})
    : this._(
        type: CloudPdfGenerationOutcomeType.unavailable,
        reason: reason,
      );

  const CloudPdfGenerationOutcome.terminalFailure({
    required Object error,
    String? reason,
  }) : this._(
         type: CloudPdfGenerationOutcomeType.terminalFailure,
         error: error,
         reason: reason,
       );

  final CloudPdfGenerationOutcomeType type;
  final File? file;
  final String? reason;
  final Object? error;
}

