/// A pre-built brand kit template that can be applied to a brand
/// to populate colors, fonts, voice, audience, and content pillars.
class BrandKitTemplate {
  final String name;
  final String description;
  final String icon;
  final List<TemplateColor> colors;
  final List<TemplateFont> fonts;
  final TemplateVoice voice;
  final TemplateAudience audience;
  final List<TemplatePillar> pillars;

  const BrandKitTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.colors,
    required this.fonts,
    required this.voice,
    required this.audience,
    required this.pillars,
  });
}

class TemplateColor {
  final String hex;
  final String label;

  const TemplateColor(this.hex, this.label);
}

class TemplateFont {
  final String family;
  final String label;
  final String weight;

  const TemplateFont(this.family, this.label, {this.weight = '600'});
}

class TemplateVoice {
  final String archetype;
  final List<String> personalityTags;
  final int toneFormal;
  final int toneSerious;
  final int toneBold;
  final String voiceSummary;
  final String tagline;
  final List<String> wordsWeUse;
  final List<String> wordsWeAvoid;

  const TemplateVoice({
    required this.archetype,
    required this.personalityTags,
    required this.toneFormal,
    required this.toneSerious,
    required this.toneBold,
    required this.voiceSummary,
    required this.tagline,
    this.wordsWeUse = const [],
    this.wordsWeAvoid = const [],
  });
}

class TemplateAudience {
  final String personaName;
  final String personaSummary;
  final int ageRangeMin;
  final int ageRangeMax;
  final List<String> interests;
  final List<String> painPoints;
  final List<String> goals;

  const TemplateAudience({
    required this.personaName,
    required this.personaSummary,
    required this.ageRangeMin,
    required this.ageRangeMax,
    this.interests = const [],
    this.painPoints = const [],
    this.goals = const [],
  });
}

class TemplatePillar {
  final String name;
  final String? description;
  final String color;

  const TemplatePillar(this.name, {this.description, this.color = '#6C63FF'});
}
