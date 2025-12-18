import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../styled_text_field.dart';

class RecipeStepsEditor extends StatefulWidget {
  final List<String> steps;
  final Function(List<String>) onStepsChanged;

  const RecipeStepsEditor({
    super.key,
    required this.steps,
    required this.onStepsChanged,
  });

  @override
  State<RecipeStepsEditor> createState() => _RecipeStepsEditorState();
}

class _RecipeStepsEditorState extends State<RecipeStepsEditor> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant RecipeStepsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps) {
      if (_controllers.length != widget.steps.length) {
         _initControllers();
      }
    }
  }

  void _initControllers() {
    for (var c in _controllers) {
      c.dispose();
    }
    _controllers.clear();

    for (var step in widget.steps) {
        final ctrl = TextEditingController(text: step);
        ctrl.addListener(_onControllerChange);
        _controllers.add(ctrl);
    }
  }

  void _onControllerChange() {
      final newSteps = _controllers.map((c) => c.text).toList();
      widget.onStepsChanged(newSteps);
  }

  void _addStep() {
      setState(() {
          final ctrl = TextEditingController();
          ctrl.addListener(_onControllerChange);
          _controllers.add(ctrl);
          widget.onStepsChanged(_controllers.map((c) => c.text).toList());
      });
  }

  void _removeStep(int index) {
      setState(() {
          _controllers[index].dispose();
          _controllers.removeAt(index);
          widget.onStepsChanged(_controllers.map((c) => c.text).toList());
      });
  }

    @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                 Text(loc.instructions, style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.w600)),
                 IconButton(
                     onPressed: _addStep,
                     icon: const Icon(Icons.add_circle, color: primaryPeach, size: 28),
                     tooltip: "Ajouter une étape",
                 )
            ],
        ),
        const SizedBox(height: 8),
        if (_controllers.isEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Aucune étape. Ajoutez-en une !", style: GoogleFonts.recursive(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
        
        ...List.generate(_controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                      child: CircleAvatar(
                          radius: 12,
                          backgroundColor: primaryPeach.withOpacity(0.2),
                          child: Text("${index + 1}", style: GoogleFonts.recursive(fontSize: 12, fontWeight: FontWeight.bold, color: primaryPeach)),
                      ),
                    ),
                    Expanded(
                        child: StyledTextField(
                            controller: _controllers[index],
                            hint: "Etape ${index + 1}...",
                            label: "Etape ${index + 1}",
                            maxLines: 3,
                        ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _removeStep(index),
                    )
                ],
            ),
          );
        }),
      ],
    );
  }
}
