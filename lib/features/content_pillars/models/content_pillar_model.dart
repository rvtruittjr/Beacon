class ContentPillarModel {
  final String? id;
  final String brandId;
  final String name;
  final String? description;
  final String color;
  final int sortOrder;
  final DateTime? createdAt;

  const ContentPillarModel({
    this.id,
    required this.brandId,
    required this.name,
    this.description,
    this.color = '#6C63FF',
    this.sortOrder = 0,
    this.createdAt,
  });

  factory ContentPillarModel.fromJson(Map<String, dynamic> json) {
    return ContentPillarModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#6C63FF',
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'name': name,
      'description': description,
      'color': color,
      'sort_order': sortOrder,
    };
  }

  ContentPillarModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? description,
    String? color,
    int? sortOrder,
  }) {
    return ContentPillarModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }
}
