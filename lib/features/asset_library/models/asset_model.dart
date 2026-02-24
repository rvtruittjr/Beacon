class AssetModel {
  final String id;
  final String brandId;
  final String? collectionId;
  final String? userId;
  final String name;
  final String? description;
  final String fileUrl;
  final String? thumbnailUrl;
  final String? fileType;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? width;
  final int? height;
  final bool isArchived;
  final DateTime createdAt;
  final List<String> tagIds;

  const AssetModel({
    required this.id,
    required this.brandId,
    this.collectionId,
    this.userId,
    required this.name,
    this.description,
    required this.fileUrl,
    this.thumbnailUrl,
    this.fileType,
    this.mimeType,
    this.fileSizeBytes,
    this.width,
    this.height,
    this.isArchived = false,
    required this.createdAt,
    this.tagIds = const [],
  });

  bool get isImage =>
      fileType == 'image' ||
      fileType == 'logo' ||
      (mimeType != null && mimeType!.startsWith('image/'));

  bool get isVideo =>
      fileType == 'video' ||
      (mimeType != null && mimeType!.startsWith('video/'));

  bool get isDocument =>
      fileType == 'document' ||
      (mimeType != null &&
          (mimeType!.startsWith('application/pdf') ||
              mimeType!.startsWith('application/msword') ||
              mimeType!.contains('document') ||
              mimeType!.contains('spreadsheet')));

  bool get isFont =>
      fileType == 'font' ||
      (mimeType != null && mimeType!.contains('font')) ||
      name.endsWith('.ttf') ||
      name.endsWith('.otf') ||
      name.endsWith('.woff');

  String get fileSizeDisplay {
    if (fileSizeBytes == null) return '';
    final bytes = fileSizeBytes!;
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      collectionId: json['collection_id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileType: json['file_type'] as String?,
      mimeType: json['mime_type'] as String?,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'collection_id': collectionId,
        'user_id': userId,
        'name': name,
        'description': description,
        'file_url': fileUrl,
        'thumbnail_url': thumbnailUrl,
        'file_type': fileType,
        'mime_type': mimeType,
        'file_size_bytes': fileSizeBytes,
        'width': width,
        'height': height,
        'is_archived': isArchived,
        'created_at': createdAt.toIso8601String(),
      };

  AssetModel copyWith({
    String? id,
    String? brandId,
    String? collectionId,
    String? userId,
    String? name,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    String? fileType,
    String? mimeType,
    int? fileSizeBytes,
    int? width,
    int? height,
    bool? isArchived,
    DateTime? createdAt,
    List<String>? tagIds,
  }) {
    return AssetModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      collectionId: collectionId ?? this.collectionId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}

class AssetCollectionModel {
  final String id;
  final String brandId;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;
  final int assetCount;

  const AssetCollectionModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.description,
    this.sortOrder = 0,
    required this.createdAt,
    this.assetCount = 0,
  });

  factory AssetCollectionModel.fromJson(Map<String, dynamic> json) {
    return AssetCollectionModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TagModel {
  final String id;
  final String userId;
  final String name;

  const TagModel({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
    );
  }
}
