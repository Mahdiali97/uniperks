class RedeemedVoucher {
  final int id;
  final int userId;
  final String username;
  final int voucherId;
  final String voucherTitle;
  final String voucherCategory;
  final int validDays;
  final DateTime redeemedAt;
  final DateTime expiresAt;

  RedeemedVoucher({
    required this.id,
    required this.userId,
    required this.username,
    required this.voucherId,
    required this.voucherTitle,
    required this.voucherCategory,
    required this.validDays,
    required this.redeemedAt,
    required this.expiresAt,
  });

  factory RedeemedVoucher.fromJson(Map<String, dynamic> json) {
    return RedeemedVoucher(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      voucherId: json['voucher_id'] as int,
      voucherTitle: json['voucher_title'] as String,
      voucherCategory: json['voucher_category'] as String,
      validDays: json['valid_days'] as int,
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired;
}
