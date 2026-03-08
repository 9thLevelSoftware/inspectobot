import 'package:pdf/pdf.dart';

import 'package:inspectobot/features/inspection/domain/condition_rating.dart';

import 'narrative_print_theme.dart';

/// PDF-layer extension on [ConditionRating] for theme-based coloring.
///
/// Keeps the domain enum free of PDF dependencies while providing
/// color mapping for narrative report rendering.
extension ConditionRatingPdfExt on ConditionRating {
  /// Returns the theme color for this rating.
  PdfColor color(NarrativePrintTheme theme) {
    switch (this) {
      case ConditionRating.satisfactory:
        return theme.ratingGood;
      case ConditionRating.marginal:
        return theme.ratingCaution;
      case ConditionRating.deficient:
        return theme.ratingDeficient;
      case ConditionRating.notInspected:
        return theme.ratingNA;
    }
  }
}
