/// Supported input field types for form section definitions.
enum FieldType {
  text,
  checkbox,
  dropdown,
  date,
  textarea,
  multiSelect,

  /// A tri-state selection field with values: 'Yes', 'No', 'N/A', or null
  /// (unanswered). For PDF mapping, each tri-state field maps to 3 checkboxes
  /// (yes_checked, no_checked, na_checked). 'N/A' counts as "complete" for
  /// required fields.
  triState,
}
