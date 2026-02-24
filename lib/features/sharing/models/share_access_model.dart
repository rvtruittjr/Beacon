class ShareAccessModel {
  final String id;
  final String brandId;
  final DateTime accessedAt;
  final String? ipAddress;
  final String status; // 'granted' or 'denied'

  const ShareAccessModel({
    required this.id,
    required this.brandId,
    required this.accessedAt,
    this.ipAddress,
    required this.status,
  });

  factory ShareAccessModel.fromJson(Map<String, dynamic> json) {
    return ShareAccessModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      accessedAt: DateTime.parse(json['accessed_at'] as String),
      ipAddress: json['ip_address'] as String?,
      status: json['status'] as String? ?? 'granted',
    );
  }
}
