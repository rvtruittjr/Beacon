class SocialKitEditState {
  final double logoOffsetX;
  final double logoOffsetY;
  final double logoScale;
  final String textContent;
  final double fontSizeMultiplier;
  final String bgColorHex;
  final String textColorHex;

  const SocialKitEditState({
    this.logoOffsetX = 0.0,
    this.logoOffsetY = 0.0,
    this.logoScale = 1.0,
    this.textContent = '',
    this.fontSizeMultiplier = 1.0,
    this.bgColorHex = '',
    this.textColorHex = '',
  });

  bool get isDefault =>
      logoOffsetX == 0.0 &&
      logoOffsetY == 0.0 &&
      logoScale == 1.0 &&
      fontSizeMultiplier == 1.0 &&
      bgColorHex.isEmpty &&
      textColorHex.isEmpty &&
      textContent.isEmpty;

  SocialKitEditState copyWith({
    double? logoOffsetX,
    double? logoOffsetY,
    double? logoScale,
    String? textContent,
    double? fontSizeMultiplier,
    String? bgColorHex,
    String? textColorHex,
  }) {
    return SocialKitEditState(
      logoOffsetX: logoOffsetX ?? this.logoOffsetX,
      logoOffsetY: logoOffsetY ?? this.logoOffsetY,
      logoScale: logoScale ?? this.logoScale,
      textContent: textContent ?? this.textContent,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      bgColorHex: bgColorHex ?? this.bgColorHex,
      textColorHex: textColorHex ?? this.textColorHex,
    );
  }
}
