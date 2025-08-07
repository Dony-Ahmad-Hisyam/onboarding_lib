// import 'package:flutter_test/flutter_test.dart';
// import 'package:onboarding_logger/onboarding_lib.dart';

// void main() {
//   group('TutorialConfig Tests', () {
//     test('should create TutorialConfig with proper values', () {
//       final config = TutorialConfig(
//         id: 'test_tutorial',
//         name: 'Test Tutorial',
//         steps: [
//           TutorialStep(
//             id: 'step_1',
//             stepNumber: 1,
//             title: 'Step 1',
//             description: 'First step',
//           ),
//         ],
//       );

//       expect(config.id, 'test_tutorial');
//       expect(config.name, 'Test Tutorial');
//       expect(config.steps.length, 1);
//       expect(config.allowSkip, true);
//       expect(config.showProgress, true);
//     });

//     test('should calculate progress correctly', () {
//       final config = TutorialConfig(
//         id: 'test_tutorial',
//         name: 'Test Tutorial',
//         steps: [
//           TutorialStep(
//             id: 'step_1',
//             stepNumber: 1,
//             title: 'Step 1',
//             description: 'First step',
//             isCompleted: true,
//           ),
//           TutorialStep(
//             id: 'step_2',
//             stepNumber: 2,
//             title: 'Step 2',
//             description: 'Second step',
//             isCompleted: false,
//           ),
//         ],
//       );

//       expect(config.getProgress(), 0.5);
//     });

//     test('should identify if tutorial is completed', () {
//       final config = TutorialConfig(
//         id: 'test_tutorial',
//         name: 'Test Tutorial',
//         steps: [
//           TutorialStep(
//             id: 'step_1',
//             stepNumber: 1,
//             title: 'Step 1',
//             description: 'First step',
//             isCompleted: true,
//           ),
//           TutorialStep(
//             id: 'step_2',
//             stepNumber: 2,
//             title: 'Step 2',
//             description: 'Second step',
//             isCompleted: true,
//           ),
//         ],
//       );

//       expect(config.isCompleted, true);
//     });
//   });

//   group('TutorialStep Tests', () {
//     test('should create TutorialStep with proper values', () {
//       final step = TutorialStep(
//         id: 'test_step',
//         stepNumber: 1,
//         title: 'Test Step',
//         description: 'Test description',
//         hasHandAnimation: true,
//       );

//       expect(step.id, 'test_step');
//       expect(step.stepNumber, 1);
//       expect(step.title, 'Test Step');
//       expect(step.description, 'Test description');
//       expect(step.hasHandAnimation, true);
//       expect(step.isCompleted, false);
//       expect(step.targets.isEmpty, true);
//     });
//   });

//   group('OnboardingLogger Tests', () {
//     setUp(() {
//       OnboardingLogger.clearLogs();
//       OnboardingLogger.setLoggingEnabled(true);
//     });

//     test('should log messages correctly', () {
//       OnboardingLogger.info('Test info message');
//       OnboardingLogger.warning('Test warning message');
//       OnboardingLogger.error('Test error message');

//       final logs = OnboardingLogger.getLogs();
//       expect(logs.length, 3);
//       expect(logs[0].contains('INFO'), true);
//       expect(logs[1].contains('WARNING'), true);
//       expect(logs[2].contains('ERROR'), true);
//     });

//     test('should log tutorial events', () {
//       OnboardingLogger.tutorialEvent('Tutorial started', data: {
//         'tutorial_id': 'test_tutorial',
//         'total_steps': 3,
//       });

//       final logs = OnboardingLogger.getLogs();
//       expect(logs.length, 1);
//       expect(logs[0].contains('TUTORIAL'), true);
//       expect(logs[0].contains('Tutorial started'), true);
//     });

//     test('should disable logging when set to false', () {
//       OnboardingLogger.setLoggingEnabled(false);
//       OnboardingLogger.info('This should not be logged');

//       final logs = OnboardingLogger.getLogs();
//       expect(logs.isEmpty, true);
//     });
//   });

//   group('TutorialUtils Tests', () {
//     test('should format step progress correctly', () {
//       final progress = TutorialUtils.formatStepProgress(2, 5);
//       expect(progress, '2 / 5');
//     });

//     test('should create simple tutorial config', () {
//       final config = TutorialUtils.createSimpleTutorial(
//         id: 'simple_tutorial',
//         name: 'Simple Tutorial',
//         stepTitles: ['Step 1', 'Step 2'],
//         stepDescriptions: ['First step', 'Second step'],
//       );

//       expect(config.id, 'simple_tutorial');
//       expect(config.name, 'Simple Tutorial');
//       expect(config.steps.length, 2);
//       expect(config.steps[0].title, 'Step 1');
//       expect(config.steps[1].title, 'Step 2');
//     });

//     test('should throw error for mismatched step arrays', () {
//       expect(
//         () => TutorialUtils.createSimpleTutorial(
//           id: 'test',
//           name: 'Test',
//           stepTitles: ['Step 1'],
//           stepDescriptions: ['First step', 'Second step'],
//         ),
//         throwsArgumentError,
//       );
//     });
//   });
// }
