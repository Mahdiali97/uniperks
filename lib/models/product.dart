class Product {
  final int? id; // Database ID (nullable for new products)
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int discount; // percentage discount
  final double rating;
  final List<Map<String, dynamic>> reviews;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.discount = 0,
    this.rating = 0.0,
    this.reviews = const [],
  });

  double get discountedPrice => price * (1 - discount / 100);

  // Convert Product to JSON for database
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'discount': discount,
      'rating': rating,
      // 'reviews' is an in-memory field only; not stored in DB by default
    };
  }

  // Convert Product to JSON for updates (excludes id)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'discount': discount,
      // Exclude 'reviews' from DB updates
    };
  }

  // Create Product from JSON (database)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String,
      discount: json['discount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}
