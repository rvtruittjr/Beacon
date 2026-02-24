class BrandModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? slug;
  final String shareToken;
  final bool isPublic;
  final String? sharePasswordHash;
  final DateTime? shareExpiresAt;
  final bool onboardingComplete;
  final DateTime createdAt;

  const BrandModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.slug,
    required this.shareToken,
    required this.isPublic,
    this.sharePasswordHash,
    this.shareExpiresAt,
    required this.onboardingComplete,
    required this.createdAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String?,
      shareToken: json['share_token'] as String,
      isPublic: json['is_public'] as bool? ?? false,
      sharePasswordHash: json['share_password_hash'] as String?,
      shareExpiresAt: json['share_expires_at'] != null
          ? DateTime.parse(json['share_expires_at'] as String)
          : null,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'slug': slug,
        'share_token': shareToken,
        'is_public': isPublic,
        'share_password_hash': sharePasswordHash,
        'share_expires_at': shareExpiresAt?.toIso8601String(),
        'onboarding_complete': onboardingComplete,
        'created_at': createdAt.toIso8601String(),
      };

  BrandModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? slug,
    String? shareToken,
    bool? isPublic,
    String? sharePasswordHash,
    DateTime? shareExpiresAt,
    bool? onboardingComplete,
    DateTime? createdAt,
  }) {
    return BrandModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      shareToken: shareToken ?? this.shareToken,
      isPublic: isPublic ?? this.isPublic,
      sharePasswordHash: sharePasswordHash ?? this.sharePasswordHash,
      shareExpiresAt: shareExpiresAt ?? this.shareExpiresAt,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
