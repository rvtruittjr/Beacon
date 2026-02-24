class SocialAccountModel {
  final String? id;
  final String brandId;
  final String platform;
  final String username;
  final String? displayName;
  final int? followerCount;
  final String? profileUrl;
  final DateTime? createdAt;

  const SocialAccountModel({
    this.id,
    required this.brandId,
    required this.platform,
    required this.username,
    this.displayName,
    this.followerCount,
    this.profileUrl,
    this.createdAt,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      platform: json['platform'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      followerCount: (json['follower_count'] as num?)?.toInt(),
      profileUrl: json['profile_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'platform': platform,
        'username': username,
        'display_name': displayName,
        'follower_count': followerCount,
        'profile_url': profileUrl,
      };

  String get followerDisplay {
    if (followerCount == null) return '';
    final c = followerCount!;
    if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
    if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
    return c.toString();
  }

  static const platforms = [
    'Instagram',
    'TikTok',
    'YouTube',
    'X (Twitter)',
    'LinkedIn',
    'Facebook',
    'Pinterest',
    'Threads',
    'Twitch',
    'Substack',
    'Other',
  ];
}
