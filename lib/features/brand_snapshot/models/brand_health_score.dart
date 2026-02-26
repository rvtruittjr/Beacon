import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/snapshot_provider.dart';

class BrandHealthSection {
  final String label;
  final String routePath;
  final IconData icon;
  final int weight;
  final bool isComplete;

  const BrandHealthSection({
    required this.label,
    required this.routePath,
    required this.icon,
    required this.weight,
    required this.isComplete,
  });
}

class BrandHealthScore {
  final List<BrandHealthSection> sections;

  const BrandHealthScore({required this.sections});

  int get totalScore =>
      sections.where((s) => s.isComplete).fold(0, (sum, s) => sum + s.weight);

  int get completedCount => sections.where((s) => s.isComplete).length;
  int get totalCount => sections.length;

  factory BrandHealthScore.fromSnapshotData(SnapshotData data) {
    return BrandHealthScore(
      sections: [
        BrandHealthSection(
          label: 'Brand Colors',
          routePath: '/app/brand-kit',
          icon: LucideIcons.palette,
          weight: 15,
          isComplete: data.colors.isNotEmpty,
        ),
        BrandHealthSection(
          label: 'Typography',
          routePath: '/app/brand-kit',
          icon: LucideIcons.type,
          weight: 15,
          isComplete: data.fonts.isNotEmpty,
        ),
        BrandHealthSection(
          label: 'Logo',
          routePath: '/app/library',
          icon: LucideIcons.image,
          weight: 15,
          isComplete: data.logos.isNotEmpty,
        ),
        BrandHealthSection(
          label: 'Voice Profile',
          routePath: '/app/voice',
          icon: LucideIcons.mic2,
          weight: 15,
          isComplete: data.voice != null,
        ),
        BrandHealthSection(
          label: 'Target Audience',
          routePath: '/app/audience',
          icon: LucideIcons.users,
          weight: 15,
          isComplete: data.audience != null,
        ),
        BrandHealthSection(
          label: 'Content Pillars',
          routePath: '/app/content-pillars',
          icon: LucideIcons.layoutGrid,
          weight: 15,
          isComplete: data.pillars.isNotEmpty,
        ),
        BrandHealthSection(
          label: 'Content Archive',
          routePath: '/app/archive',
          icon: LucideIcons.archive,
          weight: 10,
          isComplete: data.topContent.isNotEmpty,
        ),
      ],
    );
  }
}
