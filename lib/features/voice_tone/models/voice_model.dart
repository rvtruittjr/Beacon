class VoiceModel {
  final String? id;
  final String brandId;
  final String? archetype;
  final List<String> personalityTags;
  final int toneFormal;
  final int toneSerious;
  final int toneBold;
  final String? voiceSummary;
  final String? missionStatement;
  final String? tagline;
  final List<String> wordsWeUse;
  final List<String> wordsWeAvoid;

  const VoiceModel({
    this.id,
    required this.brandId,
    this.archetype,
    this.personalityTags = const [],
    this.toneFormal = 5,
    this.toneSerious = 5,
    this.toneBold = 5,
    this.voiceSummary,
    this.missionStatement,
    this.tagline,
    this.wordsWeUse = const [],
    this.wordsWeAvoid = const [],
  });

  String toneDescriptor(String dimension, int value) {
    final (low, high) = switch (dimension) {
      'formal' => ('casual', 'professional'),
      'serious' => ('playful', 'serious'),
      'bold' => ('reserved', 'bold'),
      _ => ('low', 'high'),
    };

    return switch (value) {
      1 || 2 => 'Very $low',
      3 || 4 => 'Mostly $low',
      5 || 6 => 'Balanced',
      7 || 8 => 'Mostly $high',
      _ => 'Very $high',
    };
  }

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      archetype: json['archetype'] as String?,
      personalityTags: _toStringList(json['personality_tags']),
      toneFormal: (json['tone_formal'] as num?)?.toInt() ?? 5,
      toneSerious: (json['tone_serious'] as num?)?.toInt() ?? 5,
      toneBold: (json['tone_bold'] as num?)?.toInt() ?? 5,
      voiceSummary: json['voice_summary'] as String?,
      missionStatement: json['mission_statement'] as String?,
      tagline: json['tagline'] as String?,
      wordsWeUse: _toStringList(json['words_we_use']),
      wordsWeAvoid: _toStringList(json['words_we_avoid']),
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'archetype': archetype,
        'personality_tags': personalityTags,
        'tone_formal': toneFormal,
        'tone_serious': toneSerious,
        'tone_bold': toneBold,
        'voice_summary': voiceSummary,
        'mission_statement': missionStatement,
        'tagline': tagline,
        'words_we_use': wordsWeUse,
        'words_we_avoid': wordsWeAvoid,
      };

  VoiceModel copyWith({
    String? id,
    String? brandId,
    String? archetype,
    List<String>? personalityTags,
    int? toneFormal,
    int? toneSerious,
    int? toneBold,
    String? voiceSummary,
    String? missionStatement,
    String? tagline,
    List<String>? wordsWeUse,
    List<String>? wordsWeAvoid,
  }) {
    return VoiceModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      archetype: archetype ?? this.archetype,
      personalityTags: personalityTags ?? this.personalityTags,
      toneFormal: toneFormal ?? this.toneFormal,
      toneSerious: toneSerious ?? this.toneSerious,
      toneBold: toneBold ?? this.toneBold,
      voiceSummary: voiceSummary ?? this.voiceSummary,
      missionStatement: missionStatement ?? this.missionStatement,
      tagline: tagline ?? this.tagline,
      wordsWeUse: wordsWeUse ?? this.wordsWeUse,
      wordsWeAvoid: wordsWeAvoid ?? this.wordsWeAvoid,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

class VoiceExampleModel {
  final String? id;
  final String brandId;
  final String? type;
  final String? platform;
  final String? label;
  final String content;
  final String? notes;
  final DateTime? createdAt;

  const VoiceExampleModel({
    this.id,
    required this.brandId,
    this.type,
    this.platform,
    this.label,
    required this.content,
    this.notes,
    this.createdAt,
  });

  factory VoiceExampleModel.fromJson(Map<String, dynamic> json) {
    return VoiceExampleModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      type: json['type'] as String?,
      platform: json['platform'] as String?,
      label: json['label'] as String?,
      content: json['content'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'type': type,
        'platform': platform,
        'label': label,
        'content': content,
        'notes': notes,
      };
}
