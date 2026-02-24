class BrandColorModel {
  final String id;
  final String brandId;
  final String? label;
  final String hex;
  final int sortOrder;
  final DateTime createdAt;

  const BrandColorModel({
    required this.id,
    required this.brandId,
    this.label,
    required this.hex,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory BrandColorModel.fromJson(Map<String, dynamic> json) {
    return BrandColorModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      label: json['label'] as String?,
      hex: json['hex'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'label': label,
        'hex': hex,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
      };

  BrandColorModel copyWith({
    String? id,
    String? brandId,
    String? label,
    String? hex,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return BrandColorModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      label: label ?? this.label,
      hex: hex ?? this.hex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
