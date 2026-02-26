import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

/// Font selection during onboarding (before saving to DB).
class OnboardingFont {
  final String family;
  final String? label;
  final String? weight;
  final String source; // 'google' or 'upload'
  final PlatformFile? file; // non-null when source == 'upload'

  const OnboardingFont({
    required this.family,
    this.label,
    this.weight,
    this.source = 'google',
    this.file,
  });
}

class OnboardingData {
  final int currentStep;
  final String brandName;
  final Map<String, Color> selectedColors;
  final List<OnboardingFont> selectedFonts;
  final PlatformFile? logoFile;
  final int toneFormal;
  final int toneSerious;
  final int toneBold;

  const OnboardingData({
    this.currentStep = 0,
    this.brandName = '',
    this.selectedColors = const {},
    this.selectedFonts = const [],
    this.logoFile,
    this.toneFormal = 5,
    this.toneSerious = 5,
    this.toneBold = 5,
  });

  OnboardingData copyWith({
    int? currentStep,
    String? brandName,
    Map<String, Color>? selectedColors,
    List<OnboardingFont>? selectedFonts,
    PlatformFile? logoFile,
    int? toneFormal,
    int? toneSerious,
    int? toneBold,
  }) {
    return OnboardingData(
      currentStep: currentStep ?? this.currentStep,
      brandName: brandName ?? this.brandName,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedFonts: selectedFonts ?? this.selectedFonts,
      logoFile: logoFile ?? this.logoFile,
      toneFormal: toneFormal ?? this.toneFormal,
      toneSerious: toneSerious ?? this.toneSerious,
      toneBold: toneBold ?? this.toneBold,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setBrandName(String name) {
    state = state.copyWith(brandName: name);
  }

  void addFont(OnboardingFont font) {
    state = state.copyWith(
      selectedFonts: [...state.selectedFonts, font],
    );
  }

  void removeFont(int index) {
    final updated = List<OnboardingFont>.from(state.selectedFonts)
      ..removeAt(index);
    state = state.copyWith(selectedFonts: updated);
  }

  void setColor(String label, Color color) {
    final updated = Map<String, Color>.from(state.selectedColors);
    updated[label] = color;
    state = state.copyWith(selectedColors: updated);
  }

  void setLogoFile(PlatformFile file) {
    state = state.copyWith(logoFile: file);
  }

  void setToneFormal(int value) {
    state = state.copyWith(toneFormal: value);
  }

  void setToneSerious(int value) {
    state = state.copyWith(toneSerious: value);
  }

  void setToneBold(int value) {
    state = state.copyWith(toneBold: value);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  return OnboardingNotifier();
});
