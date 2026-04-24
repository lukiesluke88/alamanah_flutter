import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String name;
  final String? lastName;
  final int age;
  final int? gender;
  final String mobile;
  final String email;
  final String? imageUrl;
  final List<String>? searchKeywords;
  final DateTime? createdAt;
  final String? description;

  User({
    this.id,
    required this.name,
    this.lastName,
    required this.age,
    this.gender,
    required this.mobile,
    required this.email,
    this.imageUrl,
    this.searchKeywords,
    this.createdAt,
    this.description
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'mobile': mobile,
      'email': email,
      'imageUrl': imageUrl,
      'searchKeywords':
          searchKeywords ?? generateSearchKeywords(name, lastName, mobile),
      'createdAt': createdAt,
      'description': description,
    };
  }

  factory User.fromJson(Map<String, dynamic> json, String docId) {
    return User(
      id: docId,
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'],
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      searchKeywords: (json['searchKeywords'] is List)
          ? List<String>.from(json['searchKeywords'])
          : [],
      createdAt: (json['createdAt'] != null)
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      description: json['description'] ?? '',
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? lastName,
    int? age,
    int? gender,
    String? mobile,
    String? email,
    String? imageUrl,
    List<String>? searchKeywords,
    DateTime? createdAt,
    String? description,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  // -----------------------------
  // 🔥 FACTORY HELPER (SAFE PLACE)
  // -----------------------------
  static List<String> generateSearchKeywords(
    String name,
    String? lastName,
    String mobile,
  ) {
    final fullName = '${name.trim()} ${lastName ?? ''}'.toLowerCase().trim();

    final words = fullName.split(' ');
    final keywords = <String>{};

    // 🔥 full name
    keywords.add(fullName);

    // 🔥 name parts + partial matching
    for (final word in words) {
      if (word.isEmpty) continue;

      keywords.add(word);

      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }

    // 🔥 mobile search support
    final cleanMobile = mobile.trim();
    keywords.add(cleanMobile);

    // optional: partial mobile search (VERY useful)
    for (int i = 1; i <= cleanMobile.length; i++) {
      keywords.add(cleanMobile.substring(0, i));
    }

    return keywords.toList();
  }
}
