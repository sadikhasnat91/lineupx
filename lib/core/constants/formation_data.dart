import '../../data/models/formation_model.dart';

/// All preset formations with their position coordinates.
///
/// Coordinate system:
///   dx = 0.0 → left edge,  dx = 1.0 → right edge
///   dy = 0.0 → opponent's goal (top),  dy = 1.0 → own goal (bottom)
class FormationData {
  FormationData._();

  // ── Position-type helpers ────────────────────────────────────────────────────
  static PositionType _pt(String label) {
    if (label == 'GK') return PositionType.gk;
    const defLabels = {'LB', 'RB', 'CB', 'LWB', 'RWB', 'SW'};
    const midLabels = {'CDM', 'CM', 'DM', 'CAM', 'LM', 'RM', 'AM'};
    if (defLabels.contains(label)) return PositionType.def;
    if (midLabels.contains(label)) return PositionType.mid;
    return PositionType.fwd;
  }

  static FormationPosition _pos(
    String id,
    String label,
    double dx,
    double dy,
  ) =>
      FormationPosition(
        id: id,
        label: label,
        positionType: _pt(label),
        dx: dx,
        dy: dy,
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 4-3-3
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f433 => FormationModel(
        id: '4-3-3',
        name: '4-3-3',
        description: 'Attacking wide play with high press',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rb', 'RB', 0.82, 0.72),
          _pos('cb1', 'CB', 0.62, 0.75),
          _pos('cb2', 'CB', 0.38, 0.75),
          _pos('lb', 'LB', 0.18, 0.72),
          _pos('cm1', 'CM', 0.74, 0.52),
          _pos('cdm', 'CDM', 0.50, 0.56),
          _pos('cm2', 'CM', 0.26, 0.52),
          _pos('rw', 'RW', 0.82, 0.22),
          _pos('st', 'ST', 0.50, 0.14),
          _pos('lw', 'LW', 0.18, 0.22),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 4-4-2
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f442 => FormationModel(
        id: '4-4-2',
        name: '4-4-2',
        description: 'Classic balanced formation',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rb', 'RB', 0.82, 0.72),
          _pos('cb1', 'CB', 0.62, 0.75),
          _pos('cb2', 'CB', 0.38, 0.75),
          _pos('lb', 'LB', 0.18, 0.72),
          _pos('rm', 'RM', 0.82, 0.50),
          _pos('cm1', 'CM', 0.62, 0.52),
          _pos('cm2', 'CM', 0.38, 0.52),
          _pos('lm', 'LM', 0.18, 0.50),
          _pos('st1', 'ST', 0.64, 0.18),
          _pos('st2', 'ST', 0.36, 0.18),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 4-2-3-1
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f4231 => FormationModel(
        id: '4-2-3-1',
        name: '4-2-3-1',
        description: 'Double pivot with attacking #10',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rb', 'RB', 0.82, 0.73),
          _pos('cb1', 'CB', 0.62, 0.76),
          _pos('cb2', 'CB', 0.38, 0.76),
          _pos('lb', 'LB', 0.18, 0.73),
          _pos('cdm1', 'CDM', 0.64, 0.57),
          _pos('cdm2', 'CDM', 0.36, 0.57),
          _pos('cam1', 'CAM', 0.80, 0.36),
          _pos('cam2', 'CAM', 0.50, 0.33),
          _pos('cam3', 'CAM', 0.20, 0.36),
          _pos('st', 'ST', 0.50, 0.14),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 3-5-2
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f352 => FormationModel(
        id: '3-5-2',
        name: '3-5-2',
        description: 'Wing-back system with two strikers',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('cb1', 'CB', 0.72, 0.74),
          _pos('cb2', 'CB', 0.50, 0.76),
          _pos('cb3', 'CB', 0.28, 0.74),
          _pos('rwb', 'RWB', 0.88, 0.50),
          _pos('cm1', 'CM', 0.68, 0.52),
          _pos('cm2', 'CM', 0.50, 0.50),
          _pos('cm3', 'CM', 0.32, 0.52),
          _pos('lwb', 'LWB', 0.12, 0.50),
          _pos('st1', 'ST', 0.64, 0.18),
          _pos('st2', 'ST', 0.36, 0.18),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 5-3-2
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f532 => FormationModel(
        id: '5-3-2',
        name: '5-3-2',
        description: 'Defensive solidity with counter threat',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rwb', 'RWB', 0.88, 0.70),
          _pos('cb1', 'CB', 0.72, 0.75),
          _pos('cb2', 'CB', 0.50, 0.77),
          _pos('cb3', 'CB', 0.28, 0.75),
          _pos('lwb', 'LWB', 0.12, 0.70),
          _pos('cm1', 'CM', 0.70, 0.50),
          _pos('cm2', 'CM', 0.50, 0.50),
          _pos('cm3', 'CM', 0.30, 0.50),
          _pos('st1', 'ST', 0.64, 0.18),
          _pos('st2', 'ST', 0.36, 0.18),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 4-5-1
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f451 => FormationModel(
        id: '4-5-1',
        name: '4-5-1',
        description: 'Compact midfield, lone striker',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rb', 'RB', 0.82, 0.73),
          _pos('cb1', 'CB', 0.62, 0.76),
          _pos('cb2', 'CB', 0.38, 0.76),
          _pos('lb', 'LB', 0.18, 0.73),
          _pos('rm', 'RM', 0.90, 0.50),
          _pos('cm1', 'CM', 0.70, 0.52),
          _pos('cm2', 'CM', 0.50, 0.52),
          _pos('cm3', 'CM', 0.30, 0.52),
          _pos('lm', 'LM', 0.10, 0.50),
          _pos('st', 'ST', 0.50, 0.14),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 3-4-3
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f343 => FormationModel(
        id: '3-4-3',
        name: '3-4-3',
        description: 'Ultra-attack overload',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('cb1', 'CB', 0.72, 0.74),
          _pos('cb2', 'CB', 0.50, 0.76),
          _pos('cb3', 'CB', 0.28, 0.74),
          _pos('rm', 'RM', 0.82, 0.52),
          _pos('cm1', 'CM', 0.60, 0.52),
          _pos('cm2', 'CM', 0.40, 0.52),
          _pos('lm', 'LM', 0.18, 0.52),
          _pos('rw', 'RW', 0.80, 0.22),
          _pos('st', 'ST', 0.50, 0.14),
          _pos('lw', 'LW', 0.20, 0.22),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // 4-1-4-1
  // ─────────────────────────────────────────────────────────────────────────────
  static FormationModel get f4141 => FormationModel(
        id: '4-1-4-1',
        name: '4-1-4-1',
        description: 'Defensive anchor + wide midfield',
        positions: [
          _pos('gk', 'GK', 0.50, 0.89),
          _pos('rb', 'RB', 0.82, 0.73),
          _pos('cb1', 'CB', 0.62, 0.76),
          _pos('cb2', 'CB', 0.38, 0.76),
          _pos('lb', 'LB', 0.18, 0.73),
          _pos('cdm', 'CDM', 0.50, 0.59),
          _pos('rm', 'RM', 0.82, 0.44),
          _pos('cm1', 'CM', 0.62, 0.44),
          _pos('cm2', 'CM', 0.38, 0.44),
          _pos('lm', 'LM', 0.18, 0.44),
          _pos('st', 'ST', 0.50, 0.14),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // All presets list
  // ─────────────────────────────────────────────────────────────────────────────
  static List<FormationModel> get all =>
      [f433, f442, f4231, f352, f532, f451, f343, f4141];

  // ─────────────────────────────────────────────────────────────────────────────
  // Position group → which Firestore positions to query
  // ─────────────────────────────────────────────────────────────────────────────
  static List<String> firestorePositionsFor(String label) {
    switch (label) {
      case 'GK':
        return ['GK'];
      case 'LB':
        return ['LB', 'LWB', 'CB'];
      case 'RB':
        return ['RB', 'RWB', 'CB'];
      case 'CB':
        return ['CB', 'LB', 'RB'];
      case 'LWB':
        return ['LWB', 'LB'];
      case 'RWB':
        return ['RWB', 'RB'];
      case 'SW':
        return ['SW', 'CB'];
      case 'CDM':
      case 'DM':
        return ['CDM', 'DM', 'CM'];
      case 'CM':
        return ['CM', 'CDM', 'CAM'];
      case 'CAM':
      case 'AM':
        return ['CAM', 'AM', 'CM', 'LW', 'RW'];
      case 'LM':
        return ['LM', 'LW', 'CM'];
      case 'RM':
        return ['RM', 'RW', 'CM'];
      case 'LW':
        return ['LW', 'LM', 'CAM', 'ST'];
      case 'RW':
        return ['RW', 'RM', 'CAM', 'ST'];
      case 'CF':
        return ['CF', 'ST', 'CAM'];
      case 'ST':
        return ['ST', 'CF', 'LW', 'RW'];
      default:
        return [label];
    }
  }
}
