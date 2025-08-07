import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

void main() {
  runApp(const TestOnboardingApp());
}

class TestOnboardingApp extends StatelessWidget {
  const TestOnboardingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Onboarding',
      home: const TestOnboardingScreen(),
    );
  }
}

class TestOnboardingScreen extends StatefulWidget {
  const TestOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<TestOnboardingScreen> createState() => _TestOnboardingScreenState();
}

class _TestOnboardingScreenState extends State<TestOnboardingScreen> {
  late OnboardingController _controller;
  final GlobalKey _buttonKey = GlobalKey(debugLabel: 'testButton');

  @override
  void initState() {
    super.initState();

    _controller = OnboardingController(
      config: OnboardingConfig(
        steps: [
          OnboardingStep(
            id: 'test_step',
            targetKey: _buttonKey,
            title: 'Test Button',
            description:
                'This is a test to verify the onboarding overlay works correctly.',
            interactionType: InteractionType.tap,
            hintIcon: Icons.touch_app,
            hintIconColor: Colors.amber,
            position: TooltipPosition.auto,
            iconPosition: IconPosition.center,
          ),
        ],
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        targetPadding: 8.0,
        tooltipConfig: const TooltipConfig(
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          maxWidth: 300,
        ),
        onComplete: () {
          print('Onboarding completed successfully!');
        },
      ),
    );

    // Start onboarding after widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _controller.start();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingOverlay(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test Onboarding'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to Test Onboarding'),
              const SizedBox(height: 20),
              ElevatedButton(
                key: _buttonKey,
                onPressed: () {
                  print('Button pressed!');
                },
                child: const Text('Test Button'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _controller.start();
                },
                child: const Text('Restart Onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
