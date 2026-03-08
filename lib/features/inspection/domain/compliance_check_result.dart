/// Result of a compliance check against statutory requirements.
class ComplianceCheckResult {
  const ComplianceCheckResult({
    required this.isCompliant,
    required this.missingElements,
    required this.warnings,
  });

  final bool isCompliant;
  final List<String> missingElements;
  final List<String> warnings;
}
