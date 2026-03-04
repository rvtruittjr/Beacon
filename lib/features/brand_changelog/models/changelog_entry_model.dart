class ChangelogEntryModel {
  final String id;
  final String brandId;
  final String action;
  final String entityType;
  final String? entityLabel;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  const ChangelogEntryModel({
    required this.id,
    required this.brandId,
    required this.action,
    required this.entityType,
    this.entityLabel,
    this.details,
    required this.createdAt,
  });

  factory ChangelogEntryModel.fromJson(Map<String, dynamic> json) {
    return ChangelogEntryModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityLabel: json['entity_label'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Human-readable summary, e.g. "Added color Primary"
  String get summary {
    final verb = switch (action) {
      'added' => 'Added',
      'updated' => 'Updated',
      'deleted' => 'Deleted',
      _ => action,
    };
    final entity = entityType;
    final label = entityLabel != null ? ' "$entityLabel"' : '';
    return '$verb $entity$label';
  }
}
