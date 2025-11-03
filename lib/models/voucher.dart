class Voucher {
  final int id;
  final String title;
  final String description;
  final String category;
  final int discount;
  final int coinsRequired;
  final int validDays;
  final bool active;
  final DateTime createdAt;

  Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.discount,
    required this.coinsRequired,
    required this.validDays,
    required this.active,
    required this.createdAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      discount: json['discount'] as int,
      coinsRequired: json['coins_required'] as int,
      validDays: json['valid_days'] as int,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'discount': discount,
      'coins_required': coinsRequired,
      'valid_days': validDays,
      'active': active,
    };
  }
}
