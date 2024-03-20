import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Indicates "`stepNumber` / `totalSteps`".
class StepIndicator extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.stepNumber,
    required this.totalSteps,
  }) : assert(stepNumber >= 1 && stepNumber <= totalSteps);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Krok $stepNumber z $totalSteps",
      textAlign: TextAlign.center,
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'StepIndicator',
  type: StepIndicator,
)
Widget previewStepIndicator(BuildContext context) {
  const totalSteps = 3;
  final stepNumber = context.knobs.int.slider(
    label: 'Step',
    initialValue: 1,
    min: 1,
    max: totalSteps,
  );

  return StepIndicator(
    stepNumber: stepNumber,
    totalSteps: totalSteps,
  );
}
