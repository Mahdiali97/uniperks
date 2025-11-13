class Order {
  final int id;
  final String username;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final int itemCount;
  final int? voucherId;
  final String? voucherTitle;
  final int? voucherDiscount;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.username,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.itemCount,
    this.voucherId,
    this.voucherTitle,
    this.voucherDiscount,
    this.status = 'paid',
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      username: json['username'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      itemCount: json['item_count'] as int,
      voucherId: json['voucher_id'] as int?,
      voucherTitle: json['voucher_title'] as String?,
      voucherDiscount: json['voucher_discount'] as int?,
      status: json['status'] as String? ?? 'paid',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
