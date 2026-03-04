import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PlatformPreset {
  final String platform;
  final String variant;
  final int width;
  final int height;
  final IconData icon;

  const PlatformPreset(
    this.platform,
    this.variant,
    this.width,
    this.height,
    this.icon,
  );

  String get displaySize => '${width}x$height';
  String get fileName =>
      '${platform.toLowerCase().replaceAll('/', '_')}_${variant.toLowerCase()}.png';

  static const all = [
    PlatformPreset('Instagram', 'Profile', 320, 320, LucideIcons.instagram),
    PlatformPreset('Instagram', 'Post', 1080, 1080, LucideIcons.instagram),
    PlatformPreset('Instagram', 'Story', 1080, 1920, LucideIcons.instagram),
    PlatformPreset('Facebook', 'Profile', 180, 180, LucideIcons.facebook),
    PlatformPreset('Facebook', 'Cover', 820, 312, LucideIcons.facebook),
    PlatformPreset('Twitter/X', 'Profile', 400, 400, LucideIcons.twitter),
    PlatformPreset('Twitter/X', 'Header', 1500, 500, LucideIcons.twitter),
    PlatformPreset('LinkedIn', 'Profile', 400, 400, LucideIcons.linkedin),
    PlatformPreset('LinkedIn', 'Banner', 1584, 396, LucideIcons.linkedin),
    PlatformPreset('YouTube', 'Profile', 800, 800, LucideIcons.youtube),
    PlatformPreset('YouTube', 'Banner', 2560, 1440, LucideIcons.youtube),
  ];

  /// Group presets by platform name.
  static Map<String, List<PlatformPreset>> get grouped {
    final map = <String, List<PlatformPreset>>{};
    for (final preset in all) {
      map.putIfAbsent(preset.platform, () => []).add(preset);
    }
    return map;
  }
}
