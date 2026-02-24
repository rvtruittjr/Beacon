extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[\w\-\.]+$').hasMatch(this);
  }

  bool isValidHex() {
    return RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$').hasMatch(this);
  }

  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
