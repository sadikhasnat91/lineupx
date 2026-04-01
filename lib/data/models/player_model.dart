import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a football player from the Firestore `players` collection.
class PlayerModel {
  final String id;
  final String name;
  final String club;
  final String country;
  final String imageUrl;
  final int number;
  final List<String> positions; // e.g. ['ST', 'CF', 'LW']
  final int rating;
  final int age;
  final String preferredFoot; // 'Right' | 'Left' | 'Both'

  const PlayerModel({
    required this.id,
    required this.name,
    required this.club,
    required this.country,
    required this.imageUrl,
    required this.number,
    required this.positions,
    required this.rating,
    required this.age,
    required this.preferredFoot,
  });

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      club: data['club'] as String? ?? '',
      country: data['country'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      number: (data['number'] as num?)?.toInt() ?? 0,
      positions: List<String>.from(data['positions'] as List? ?? []),
      rating: (data['rating'] as num?)?.toInt() ?? 70,
      age: (data['age'] as num?)?.toInt() ?? 0,
      preferredFoot: data['preferredFoot'] as String? ?? 'Right',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'club': club,
        'country': country,
        'imageUrl': imageUrl,
        'number': number,
        'positions': positions,
        'rating': rating,
        'age': age,
        'preferredFoot': preferredFoot,
      };

  // ── JSON (Hive caching) ──────────────────────────────────────────────────────

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        club: json['club'] as String? ?? '',
        country: json['country'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        number: (json['number'] as num?)?.toInt() ?? 0,
        positions: List<String>.from(json['positions'] as List? ?? []),
        rating: (json['rating'] as num?)?.toInt() ?? 70,
        age: (json['age'] as num?)?.toInt() ?? 0,
        preferredFoot: json['preferredFoot'] as String? ?? 'Right',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'club': club,
        'country': country,
        'imageUrl': imageUrl,
        'number': number,
        'positions': positions,
        'rating': rating,
        'age': age,
        'preferredFoot': preferredFoot,
      };

  PlayerModel copyWith({
    String? id,
    String? name,
    String? club,
    String? country,
    String? imageUrl,
    int? number,
    List<String>? positions,
    int? rating,
    int? age,
    String? preferredFoot,
  }) =>
      PlayerModel(
        id: id ?? this.id,
        name: name ?? this.name,
        club: club ?? this.club,
        country: country ?? this.country,
        imageUrl: imageUrl ?? this.imageUrl,
        number: number ?? this.number,
        positions: positions ?? this.positions,
        rating: rating ?? this.rating,
        age: age ?? this.age,
        preferredFoot: preferredFoot ?? this.preferredFoot,
      );

  String get primaryPosition =>
      positions.isNotEmpty ? positions.first : 'Unknown';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlayerModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlayerModel(id: $id, name: $name, rating: $rating)';
}
