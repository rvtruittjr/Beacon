class AudienceModel {
  final String? id;
  final String brandId;
  final String? personaName;
  final String? personaSummary;
  final int? ageRangeMin;
  final int? ageRangeMax;
  final String? genderSkew;
  final List<String> locations;
  final List<String> interests;
  final List<String> painPoints;
  final List<String> goals;
  final DateTime? updatedAt;

  const AudienceModel({
    this.id,
    required this.brandId,
    this.personaName,
    this.personaSummary,
    this.ageRangeMin,
    this.ageRangeMax,
    this.genderSkew,
    this.locations = const [],
    this.interests = const [],
    this.painPoints = const [],
    this.goals = const [],
    this.updatedAt,
  });

  bool get isEmpty =>
      personaName == null &&
      personaSummary == null &&
      ageRangeMin == null &&
      ageRangeMax == null &&
      genderSkew == null &&
      locations.isEmpty &&
      interests.isEmpty &&
      painPoints.isEmpty &&
      goals.isEmpty;

  factory AudienceModel.fromJson(Map<String, dynamic> json) {
    return AudienceModel(
      id: json['id'] as String?,
      brandId: json['brand_id'] as String,
      personaName: json['persona_name'] as String?,
      personaSummary: json['persona_summary'] as String?,
      ageRangeMin: (json['age_range_min'] as num?)?.toInt(),
      ageRangeMax: (json['age_range_max'] as num?)?.toInt(),
      genderSkew: json['gender_skew'] as String?,
      locations: _toStringList(json['locations']),
      interests: _toStringList(json['interests']),
      painPoints: _toStringList(json['pain_points']),
      goals: _toStringList(json['goals']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'persona_name': personaName,
        'persona_summary': personaSummary,
        'age_range_min': ageRangeMin,
        'age_range_max': ageRangeMax,
        'gender_skew': genderSkew,
        'locations': locations,
        'interests': interests,
        'pain_points': painPoints,
        'goals': goals,
      };

  AudienceModel copyWith({
    String? id,
    String? brandId,
    String? personaName,
    String? personaSummary,
    int? ageRangeMin,
    int? ageRangeMax,
    String? genderSkew,
    List<String>? locations,
    List<String>? interests,
    List<String>? painPoints,
    List<String>? goals,
  }) {
    return AudienceModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      personaName: personaName ?? this.personaName,
      personaSummary: personaSummary ?? this.personaSummary,
      ageRangeMin: ageRangeMin ?? this.ageRangeMin,
      ageRangeMax: ageRangeMax ?? this.ageRangeMax,
      genderSkew: genderSkew ?? this.genderSkew,
      locations: locations ?? this.locations,
      interests: interests ?? this.interests,
      painPoints: painPoints ?? this.painPoints,
      goals: goals ?? this.goals,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
