import 'package:flutter/material.dart';

/// Types of position on the pitch.
enum PositionType { gk, def, mid, fwd }

/// A single position slot within a formation, with its normalised coordinates.
class FormationPosition {
  final String id; // unique within formation, e.g. 'cb1'
  final String label; // e.g. 'CB', 'ST'
  final PositionType positionType;
  final double dx; // 0.0 = left, 1.0 = right
  final double dy; // 0.0 = opponent's goal (top), 1.0 = own goal (bottom)

  const FormationPosition({
    required this.id,
    required this.label,
    required this.positionType,
    required this.dx,
    required this.dy,
  });

  Offset get offset => Offset(dx, dy);

  factory FormationPosition.fromJson(Map<String, dynamic> json) =>
      FormationPosition(
        id: json['id'] as String,
        label: json['label'] as String,
        positionType: PositionType.values.firstWhere(
          (e) => e.name == json['positionType'],
          orElse: () => PositionType.mid,
        ),
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'positionType': positionType.name,
        'dx': dx,
        'dy': dy,
      };

  FormationPosition copyWith({
    String? id,
    String? label,
    PositionType? positionType,
    double? dx,
    double? dy,
  }) =>
      FormationPosition(
        id: id ?? this.id,
        label: label ?? this.label,
        positionType: positionType ?? this.positionType,
        dx: dx ?? this.dx,
        dy: dy ?? this.dy,
      );
}

/// A complete formation definition.
class FormationModel {
  final String id; // unique id, same as name for presets e.g. '4-3-3'
  final String name;
  final String description;
  final List<FormationPosition> positions; // exactly 11 slots
  final bool isCustom;

  const FormationModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.positions,
    this.isCustom = false,
  });

  factory FormationModel.fromJson(Map<String, dynamic> json) => FormationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        positions: (json['positions'] as List)
            .map((e) => FormationPosition.fromJson(e as Map<String, dynamic>))
            .toList(),
        isCustom: json['isCustom'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'positions': positions.map((p) => p.toJson()).toList(),
        'isCustom': isCustom,
      };

  FormationModel copyWith({
    String? id,
    String? name,
    String? description,
    List<FormationPosition>? positions,
    bool? isCustom,
  }) =>
      FormationModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        positions: positions ?? this.positions,
        isCustom: isCustom ?? this.isCustom,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FormationModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
