class Plan {
  final String title;
  final String price;
  final List<String> features;
  final bool isActive;
  final String description;

  Plan({
    required this.title,
    required this.price,
    required this.features,
    required this.isActive,
    required this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      title: json['title'],
      price: json['price'],
      features: List<String>.from(json['features']),
      isActive: json['isActive'],
      description: json['description'],
    );
  }
}
