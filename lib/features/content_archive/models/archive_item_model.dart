class ArchiveItemModel {
  final String? id;
  final String brandId;
  final String title;
  final String? platform;
  final String? contentUrl;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? hook;
  final int? views;
  final int? likes;
  final int? comments;
  final DateTime? datePosted;
  final String? pillarId;
  final String? pillarName;
  final String? pillarColor;
  final String? notes;
  final DateTime? createdAt;

  const ArchiveItemModel({
    this.id,
    required this.brandId,
    required this.title,
    this.platform,
    this.contentUrl,
    this.thumbnailUrl,
    this.videoUrl,
    this.hook,
    this.views,
    this.likes,
    this.comments,
    this.datePosted,
    this.pillarId,
    this.pillarName,
    this.pillarColor,
    this.notes,
    this.createdAt,
  });

  /// Human-readable engagement summary, e.g. "1.2K views · 350 likes · 42 comments"
  String get engagementSummary {
    final parts = <String>[];
    if (views != null && views! > 0) parts.add('${compact(views!)} views');
    if (likes != null && likes! > 0) parts.add('${compact(likes!)} likes');
    if (comments != null && comments! > 0) {
      parts.add('${compact(comments!)} comments');
    }
    return parts.isEmpty ? 'No engagement data' : parts.join(' · ');
  }

  static String compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  factory ArchiveItemModel.fromJson(Map<String, dynamic> json) {
    // If pillar is joined as a map, extract name/color
    final pillar = json['content_pillars'] as Map<String, dynamic>?;

    return ArchiveItemModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      platform: json['platform'] as String?,
      contentUrl: json['content_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      hook: json['hook'] as String?,
      views: json['views'] as int?,
      likes: json['likes'] as int?,
      comments: json['comments'] as int?,
      datePosted: json['date_posted'] != null
          ? DateTime.tryParse(json['date_posted'] as String)
          : null,
      pillarId: json['pillar_id'] as String?,
      pillarName: pillar?['name'] as String?,
      pillarColor: pillar?['color'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'title': title,
      if (platform != null) 'platform': platform,
      if (contentUrl != null) 'content_url': contentUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (hook != null) 'hook': hook,
      if (views != null) 'views': views,
      if (likes != null) 'likes': likes,
      if (comments != null) 'comments': comments,
      if (datePosted != null) 'date_posted': datePosted!.toIso8601String(),
      if (pillarId != null) 'pillar_id': pillarId,
      if (notes != null) 'notes': notes,
    };
  }

  ArchiveItemModel copyWith({
    String? id,
    String? brandId,
    String? title,
    String? platform,
    String? contentUrl,
    String? thumbnailUrl,
    String? videoUrl,
    String? hook,
    int? views,
    int? likes,
    int? comments,
    DateTime? datePosted,
    String? pillarId,
    String? pillarName,
    String? pillarColor,
    String? notes,
  }) {
    return ArchiveItemModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      contentUrl: contentUrl ?? this.contentUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      hook: hook ?? this.hook,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      datePosted: datePosted ?? this.datePosted,
      pillarId: pillarId ?? this.pillarId,
      pillarName: pillarName ?? this.pillarName,
      pillarColor: pillarColor ?? this.pillarColor,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
