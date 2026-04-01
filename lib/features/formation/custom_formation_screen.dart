import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/formation_model.dart';
import '../../widgets/gradient_app_bar.dart';
import 'formation_controller.dart';

/// Drag-to-position custom formation builder.
class CustomFormationScreen extends StatefulWidget {
  const CustomFormationScreen({super.key});

  @override
  State<CustomFormationScreen> createState() =>
      _CustomFormationScreenState();
}

class _CustomFormationScreenState extends State<CustomFormationScreen> {
  final _nameController = TextEditingController(text: 'My Formation');
  final _positions = <_DraggablePosition>[];
  final _pitchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start with 1 GK + 10 outfield players in a basic 4-3-3-like layout
    _addDefault();
  }

  void _addDefault() {
    _positions.addAll([
      _DraggablePosition('gk', 'GK', 0.5, 0.88),
      _DraggablePosition('rb', 'RB', 0.82, 0.72),
      _DraggablePosition('cb1', 'CB', 0.62, 0.75),
      _DraggablePosition('cb2', 'CB', 0.38, 0.75),
      _DraggablePosition('lb', 'LB', 0.18, 0.72),
      _DraggablePosition('cm1', 'CM', 0.74, 0.52),
      _DraggablePosition('cdm', 'CDM', 0.5, 0.56),
      _DraggablePosition('cm2', 'CM', 0.26, 0.52),
      _DraggablePosition('rw', 'RW', 0.82, 0.22),
      _DraggablePosition('st', 'ST', 0.5, 0.14),
      _DraggablePosition('lw', 'LW', 0.18, 0.22),
    ]);
  }

  void _addPosition() {
    setState(() {
      _positions.add(
          _DraggablePosition(const Uuid().v4(), 'CM', 0.5, 0.5));
    });
  }

  void _removePosition(_DraggablePosition pos) {
    if (_positions.length <= 3) {
      Get.snackbar('Minimum', 'Formation needs at least 3 positions',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.textPrimary);
      return;
    }
    setState(() => _positions.remove(pos));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter a formation name',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.textPrimary);
      return;
    }

    final id = const Uuid().v4();

    final formation = FormationModel(
      id: id,
      name: name,
      description: 'Custom formation',
      isCustom: true,
      positions: _positions.map((p) {
        PositionType pt;
        if (p.label == 'GK') {
          pt = PositionType.gk;
        } else if ({'LB', 'RB', 'CB', 'LWB', 'RWB'}.contains(p.label)) {
          pt = PositionType.def;
        } else if ({'CDM', 'CM', 'CAM', 'LM', 'RM'}.contains(p.label)) {
          pt = PositionType.mid;
        } else {
          pt = PositionType.fwd;
        }
        return FormationPosition(
          id: p.id,
          label: p.label,
          positionType: pt,
          dx: p.dx,
          dy: p.dy,
        );
      }).toList(),
    );

    await Get.find<FormationController>().saveCustomFormation(formation);
    Get.back();
    Get.snackbar('Saved', 'Custom formation "$name" saved!',
        backgroundColor: AppColors.bgCard,
        colorText: AppColors.accentGreen);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(
        title: 'Custom Formation',
        actions: [
          TextButton(
            onPressed: _addPosition,
            child: const Text('+ADD',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Formation name input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Formation name',
                prefixIcon: Icon(Icons.edit_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
          ),

          // Pitch
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pitchW = constraints.maxWidth;
                  final pitchH = constraints.maxHeight;

                  return Stack(
                    key: _pitchKey,
                    children: [
                      // Pitch painter
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomPaint(
                            painter: _CustomPitchPainter(),
                          ),
                        ),
                      ),

                      // Draggable positions
                      ..._positions.map(
                        (pos) => _DraggableSlot(
                          key: ValueKey(pos.id),
                          position: pos,
                          pitchW: pitchW,
                          pitchH: pitchH,
                          onMove: (nx, ny) {
                            setState(() {
                              pos.dx = nx;
                              pos.dy = ny;
                            });
                          },
                          onLabelChange: (label) {
                            setState(() => pos.label = label);
                          },
                          onDelete: () => _removePosition(pos),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Save Formation',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Draggable position slot ───────────────────────────────────────────────────

class _DraggablePosition {
  String id;
  String label;
  double dx;
  double dy;

  _DraggablePosition(this.id, this.label, this.dx, this.dy);
}

class _DraggableSlot extends StatelessWidget {
  final _DraggablePosition position;
  final double pitchW;
  final double pitchH;
  final void Function(double nx, double ny) onMove;
  final void Function(String label) onLabelChange;
  final VoidCallback onDelete;

  const _DraggableSlot({
    super.key,
    required this.position,
    required this.pitchW,
    required this.pitchH,
    required this.onMove,
    required this.onLabelChange,
    required this.onDelete,
  });

  static const _slotW = 42.0;
  static const _slotH = 42.0;

  @override
  Widget build(BuildContext context) {
    final x = position.dx * pitchW - _slotW / 2;
    final y = position.dy * pitchH - _slotH / 2;

    return Positioned(
      left: x.clamp(0, pitchW - _slotW),
      top: y.clamp(0, pitchH - _slotH),
      child: GestureDetector(
        onPanUpdate: (details) {
          final newX =
              ((position.dx * pitchW + details.delta.dx) / pitchW)
                  .clamp(0.05, 0.95);
          final newY =
              ((position.dy * pitchH + details.delta.dy) / pitchH)
                  .clamp(0.05, 0.95);
          onMove(newX, newY);
        },
        onLongPress: () => _showOptions(context),
        child: Container(
          width: _slotW,
          height: _slotH,
          decoration: BoxDecoration(
            color: AppColors.bgDark.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentGreen, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.3),
                blurRadius: 8,
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            position.label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.accentGreen,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final labels = [
      'GK', 'LB', 'CB', 'RB', 'LWB', 'RWB',
      'CDM', 'CM', 'CAM', 'LM', 'RM',
      'LW', 'RW', 'CF', 'ST'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Position',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labels
                  .map((l) => GestureDetector(
                        onTap: () {
                          onLabelChange(l);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: position.label == l
                                ? AppColors.accentGreen
                                : AppColors.bgCardElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l,
                            style: TextStyle(
                              color: position.label == l
                                  ? Colors.black87
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 16),
              label: const Text('Remove Slot',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grass gradient
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.pitchDark, AppColors.pitchMid, AppColors.pitchDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final line = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final pad = size.width * 0.04;
    // Outer
    canvas.drawRect(
        Rect.fromLTWH(
            pad, pad * 0.5, size.width - pad * 2, size.height - pad),
        line);
    // Centre line
    canvas.drawLine(
        Offset(pad, size.height / 2),
        Offset(size.width - pad, size.height / 2),
        line);
    // Centre circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.15, line);
    // Penalty areas
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.22, pad * 0.5, size.width * 0.56,
            size.height * 0.18),
        line);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.82 - pad * 0.5,
            size.width * 0.56, size.height * 0.18),
        line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
