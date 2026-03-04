import '../../../features/audience/data/audience_repository.dart';
import '../../../features/audience/models/audience_model.dart';
import '../../../features/content_pillars/data/content_pillar_repository.dart';
import '../../../features/content_pillars/models/content_pillar_model.dart';
import '../../../features/voice_tone/data/voice_repository.dart';
import '../../../features/voice_tone/models/voice_model.dart';
import '../data/colors_repository.dart';
import '../data/fonts_repository.dart';
import '../models/brand_kit_template.dart';

class TemplateService {
  final ColorsRepository colorsRepo;
  final FontsRepository fontsRepo;
  final VoiceRepository voiceRepo;
  final AudienceRepository audienceRepo;
  final ContentPillarRepository pillarRepo;

  TemplateService({
    required this.colorsRepo,
    required this.fontsRepo,
    required this.voiceRepo,
    required this.audienceRepo,
    required this.pillarRepo,
  });

  /// Applies a template to the given brand.
  /// Colors, fonts, and pillars are appended.
  /// Voice and audience are upserted (overwrite existing).
  Future<void> applyTemplate(String brandId, BrandKitTemplate template) async {
    // Colors
    for (final color in template.colors) {
      await colorsRepo.addColor(
        brandId: brandId,
        hex: color.hex,
        label: color.label,
      );
    }

    // Fonts
    for (final font in template.fonts) {
      await fontsRepo.addFont(
        brandId: brandId,
        family: font.family,
        label: font.label,
        weight: font.weight,
        source: 'google',
      );
    }

    // Voice (upsert — overwrites)
    await voiceRepo.upsertVoice(
      brandId,
      VoiceModel(
        brandId: brandId,
        archetype: template.voice.archetype,
        personalityTags: template.voice.personalityTags,
        toneFormal: template.voice.toneFormal,
        toneSerious: template.voice.toneSerious,
        toneBold: template.voice.toneBold,
        voiceSummary: template.voice.voiceSummary,
        tagline: template.voice.tagline,
        wordsWeUse: template.voice.wordsWeUse,
        wordsWeAvoid: template.voice.wordsWeAvoid,
      ),
    );

    // Audience (upsert — overwrites)
    await audienceRepo.upsertAudience(
      brandId,
      AudienceModel(
        brandId: brandId,
        personaName: template.audience.personaName,
        personaSummary: template.audience.personaSummary,
        ageRangeMin: template.audience.ageRangeMin,
        ageRangeMax: template.audience.ageRangeMax,
        interests: template.audience.interests,
        painPoints: template.audience.painPoints,
        goals: template.audience.goals,
      ),
    );

    // Content pillars (appended, silently skip if free-tier limit hit)
    for (final pillar in template.pillars) {
      try {
        await pillarRepo.addPillar(ContentPillarModel(
          brandId: brandId,
          name: pillar.name,
          description: pillar.description,
          color: pillar.color,
        ));
      } catch (_) {
        // Free-tier limit reached — skip remaining pillars
        break;
      }
    }
  }
}
