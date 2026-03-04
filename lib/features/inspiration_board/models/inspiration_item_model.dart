class InspirationItemModel {
  final String id;
  final String brandId;
  final String imageUrl;
  final String? caption;
  final double posX;
  final double posY;
  final double width;
  final double height;
  final int sortOrder;
  final DateTime createdAt;

  const InspirationItemModel({
    required this.id,
    required this.brandId,
    required this.imageUrl,
    this.caption,
    this.posX = 0,
    this.posY = 0,
    this.width = 200,
    this.height = 200,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory InspirationItemModel.fromJson(Map<String, dynamic> json) {
    return InspirationItemModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      posX: (json['pos_x'] as num).toDouble(),
      posY: (json['pos_y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  InspirationItemModel copyWith({
    String? id,
    String? brandId,
    String? imageUrl,
    String? caption,
    double? posX,
    double? posY,
    double? width,
    double? height,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return InspirationItemModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      width: width ?? this.width,
      height: height ?? this.height,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
