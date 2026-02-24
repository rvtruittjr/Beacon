class BrandFontModel {
  final String id;
  final String brandId;
  final String? label;
  final String family;
  final String? weight;
  final String? source;
  final String? url;
  final int sortOrder;

  const BrandFontModel({
    required this.id,
    required this.brandId,
    this.label,
    required this.family,
    this.weight,
    this.source,
    this.url,
    this.sortOrder = 0,
  });

  factory BrandFontModel.fromJson(Map<String, dynamic> json) {
    return BrandFontModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      label: json['label'] as String?,
      family: json['family'] as String,
      weight: json['weight'] as String?,
      source: json['source'] as String?,
      url: json['url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'label': label,
        'family': family,
        'weight': weight,
        'source': source,
        'url': url,
        'sort_order': sortOrder,
      };

  BrandFontModel copyWith({
    String? id,
    String? brandId,
    String? label,
    String? family,
    String? weight,
    String? source,
    String? url,
    int? sortOrder,
  }) {
    return BrandFontModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      label: label ?? this.label,
      family: family ?? this.family,
      weight: weight ?? this.weight,
      source: source ?? this.source,
      url: url ?? this.url,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
