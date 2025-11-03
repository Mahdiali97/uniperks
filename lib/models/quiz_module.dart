class QuizModule {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final bool active;

  QuizModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.active = true,
  });

  factory QuizModule.fromJson(Map<String, dynamic> json) {
    return QuizModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'active': active,
    };
  }
}
