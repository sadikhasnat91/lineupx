import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a football player from the Firestore `players` collection.
class PlayerModel {
  final String id;
  final String name;
  final String club;
  final String country;
  final String imageUrl;
  final String clubLogoUrl;
  final int number;
  final List<String> positions; // e.g. ['ST', 'CF', 'LW']
  final int rating;
  final int age;
  final String preferredFoot; // 'Right' | 'Left' | 'Both'

  // Detailed stats
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defending;
  final int physical;
  final int potential;
  final int weakFoot;
  final int skillMoves;
  final String height;
  final String weight;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.club,
    required this.country,
    required this.imageUrl,
    this.clubLogoUrl = '',
    required this.number,
    required this.positions,
    required this.rating,
    required this.age,
    required this.preferredFoot,
    this.pace = 0,
    this.shooting = 0,
    this.passing = 0,
    this.dribbling = 0,
    this.defending = 0,
    this.physical = 0,
    this.potential = 0,
    this.weakFoot = 0,
    this.skillMoves = 0,
    this.height = '',
    this.weight = '',
  });

  // ── Asset JSON (bundled player data) ─────────────────────────────────────────

  factory PlayerModel.fromAssetJson(Map<String, dynamic> j) {
    final int numericId = (j['id'] as num?)?.toInt() ?? 0;
    final String id = numericId.toString();
    return PlayerModel(
      id: id,
      name: j['name'] as String? ?? '',
      club: j['club'] as String? ?? '',
      country: j['nationality'] as String? ?? '',
      imageUrl: j['imageUrl'] as String? ?? '',
      clubLogoUrl: j['clubLogoUrl'] as String? ?? '',
      number: (j['number'] as num?)?.toInt() ?? 0,
      positions: [j['position'] as String? ?? 'ST'],
      rating: (j['overall'] as num?)?.toInt() ?? 70,
      age: (j['age'] as num?)?.toInt() ?? 0,
      preferredFoot: j['preferredFoot'] as String? ?? 'Right',
      pace: (j['pace'] as num?)?.toInt() ?? 0,
      shooting: (j['shooting'] as num?)?.toInt() ?? 0,
      passing: (j['passing'] as num?)?.toInt() ?? 0,
      dribbling: (j['dribbling'] as num?)?.toInt() ?? 0,
      defending: (j['defending'] as num?)?.toInt() ?? 0,
      physical: (j['physical'] as num?)?.toInt() ?? 0,
      potential: (j['potential'] as num?)?.toInt() ?? 0,
      weakFoot: (j['weakFoot'] as num?)?.toInt() ?? 0,
      skillMoves: (j['skillMoves'] as num?)?.toInt() ?? 0,
      height: j['height']?.toString() ?? '',
      weight: j['weight']?.toString() ?? '',
    );
  }

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      club: data['club'] as String? ?? '',
      country: data['country'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      clubLogoUrl: data['clubLogoUrl'] as String? ?? '',
      number: (data['number'] as num?)?.toInt() ?? 0,
      positions: List<String>.from(data['positions'] as List? ?? []),
      rating: (data['rating'] as num?)?.toInt() ?? 70,
      age: (data['age'] as num?)?.toInt() ?? 0,
      preferredFoot: data['preferredFoot'] as String? ?? 'Right',
      pace: (data['pace'] as num?)?.toInt() ?? 0,
      shooting: (data['shooting'] as num?)?.toInt() ?? 0,
      passing: (data['passing'] as num?)?.toInt() ?? 0,
      dribbling: (data['dribbling'] as num?)?.toInt() ?? 0,
      defending: (data['defending'] as num?)?.toInt() ?? 0,
      physical: (data['physical'] as num?)?.toInt() ?? 0,
      potential: (data['potential'] as num?)?.toInt() ?? 0,
      weakFoot: (data['weakFoot'] as num?)?.toInt() ?? 0,
      skillMoves: (data['skillMoves'] as num?)?.toInt() ?? 0,
      height: data['height']?.toString() ?? '',
      weight: data['weight']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'club': club,
        'country': country,
        'imageUrl': imageUrl,
        'clubLogoUrl': clubLogoUrl,
        'number': number,
        'positions': positions,
        'rating': rating,
        'age': age,
        'preferredFoot': preferredFoot,
        'pace': pace,
        'shooting': shooting,
        'passing': passing,
        'dribbling': dribbling,
        'defending': defending,
        'physical': physical,
        'potential': potential,
        'weakFoot': weakFoot,
        'skillMoves': skillMoves,
        'height': height,
        'weight': weight,
      };

  // ── Custom (user-typed) player ───────────────────────────────────────────────

  factory PlayerModel.custom({
    required String name,
    String position = 'CM',
    int number = 0,
  }) {
    return PlayerModel(
      id: 'custom_${name.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      club: '',
      country: '',
      imageUrl: '',
      clubLogoUrl: '',
      number: number,
      positions: [position],
      rating: 75,
      age: 0,
      preferredFoot: 'Right',
    );
  }

  // ── JSON (Hive caching) ──────────────────────────────────────────────────────

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        club: json['club'] as String? ?? '',
        country: json['country'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        clubLogoUrl: json['clubLogoUrl'] as String? ?? '',
        number: (json['number'] as num?)?.toInt() ?? 0,
        positions: List<String>.from(json['positions'] as List? ?? []),
        rating: (json['rating'] as num?)?.toInt() ?? 70,
        age: (json['age'] as num?)?.toInt() ?? 0,
        preferredFoot: json['preferredFoot'] as String? ?? 'Right',
        pace: (json['pace'] as num?)?.toInt() ?? 0,
        shooting: (json['shooting'] as num?)?.toInt() ?? 0,
        passing: (json['passing'] as num?)?.toInt() ?? 0,
        dribbling: (json['dribbling'] as num?)?.toInt() ?? 0,
        defending: (json['defending'] as num?)?.toInt() ?? 0,
        physical: (json['physical'] as num?)?.toInt() ?? 0,
        potential: (json['potential'] as num?)?.toInt() ?? 0,
        weakFoot: (json['weakFoot'] as num?)?.toInt() ?? 0,
        skillMoves: (json['skillMoves'] as num?)?.toInt() ?? 0,
        height: json['height']?.toString() ?? '',
        weight: json['weight']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'club': club,
        'country': country,
        'imageUrl': imageUrl,
        'clubLogoUrl': clubLogoUrl,
        'number': number,
        'positions': positions,
        'rating': rating,
        'age': age,
        'preferredFoot': preferredFoot,
        'pace': pace,
        'shooting': shooting,
        'passing': passing,
        'dribbling': dribbling,
        'defending': defending,
        'physical': physical,
        'potential': potential,
        'weakFoot': weakFoot,
        'skillMoves': skillMoves,
        'height': height,
        'weight': weight,
      };

  PlayerModel copyWith({
    String? id,
    String? name,
    String? club,
    String? country,
    String? imageUrl,
    String? clubLogoUrl,
    int? number,
    List<String>? positions,
    int? rating,
    int? age,
    String? preferredFoot,
    int? pace,
    int? shooting,
    int? passing,
    int? dribbling,
    int? defending,
    int? physical,
    int? potential,
    int? weakFoot,
    int? skillMoves,
    String? height,
    String? weight,
  }) =>
      PlayerModel(
        id: id ?? this.id,
        name: name ?? this.name,
        club: club ?? this.club,
        country: country ?? this.country,
        imageUrl: imageUrl ?? this.imageUrl,
        clubLogoUrl: clubLogoUrl ?? this.clubLogoUrl,
        number: number ?? this.number,
        positions: positions ?? this.positions,
        rating: rating ?? this.rating,
        age: age ?? this.age,
        preferredFoot: preferredFoot ?? this.preferredFoot,
        pace: pace ?? this.pace,
        shooting: shooting ?? this.shooting,
        passing: passing ?? this.passing,
        dribbling: dribbling ?? this.dribbling,
        defending: defending ?? this.defending,
        physical: physical ?? this.physical,
        potential: potential ?? this.potential,
        weakFoot: weakFoot ?? this.weakFoot,
        skillMoves: skillMoves ?? this.skillMoves,
        height: height ?? this.height,
        weight: weight ?? this.weight,
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
