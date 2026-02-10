class User {
  final String name;
  final String initials;
  final String registrationNumber;
  final String plan;

  const User({
    required this.name,
    required this.initials,
    required this.registrationNumber,
    required this.plan,
  });

  // Factory constructor for creating a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      initials: json['initials'] as String,
      registrationNumber: json['registrationNumber'] as String,
      plan: json['plan'] as String,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'initials': initials,
      'registrationNumber': registrationNumber,
      'plan': plan,
    };
  }

  // Create a copy with modified fields
  User copyWith({
    String? name,
    String? initials,
    String? registrationNumber,
    String? plan,
  }) {
    return User(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      plan: plan ?? this.plan,
    );
  }

  // Default user for testing/demo
  static const User demo = User(
    name: 'Arun Kumar',
    initials: 'AK',
    registrationNumber: 'CRO0868054',
    plan: 'Monthly',
  );
}
