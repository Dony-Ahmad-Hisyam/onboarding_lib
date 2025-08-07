import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

class MathGameDemo extends StatefulWidget {
  const MathGameDemo({Key? key}) : super(key: key);

  @override
  State<MathGameDemo> createState() => _MathGameDemoState();
}

class _MathGameDemoState extends State<MathGameDemo> {
  late OnboardingController _onboardingController;

  // Define GlobalKeys as final fields
  final GlobalKey _gameSelectionKey = GlobalKey(debugLabel: 'gameSelectionKey');
  final GlobalKey _mathProblemKey = GlobalKey(debugLabel: 'mathProblemKey');
  final GlobalKey _number3Key = GlobalKey(debugLabel: 'number3Key');
  final GlobalKey _emptyCircleKey = GlobalKey(debugLabel: 'emptyCircleKey');

  @override
  void initState() {
    super.initState();
    _initOnboarding();

    // Start onboarding after a short delay to ensure widgets are laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _onboardingController.start();
      });
    });
  }

  void _initOnboarding() {
    final steps = [
      OnboardingStep(
        id: 'select_game',
        targetKey: _gameSelectionKey,
        title: 'Choose a Mini-game',
        description:
            'Tap on a game to start playing and learning math concepts.',
        interactionType: InteractionType.tap,
        hintIcon: Icons.touch_app,
        hintIconColor: Colors.amber,
        position: TooltipPosition.bottom,
        iconPosition: IconPosition.topRight,
      ),
      OnboardingStep(
        id: 'math_problem',
        targetKey: _mathProblemKey,
        title: 'Play, Learn and Earn Coins',
        description:
            'Solve math problems to earn coins and progress through the levels.',
        interactionType: InteractionType.tap,
        hintIcon: Icons.touch_app,
        hintIconColor: Colors.amber,
        position: TooltipPosition.bottom,
        iconPosition: IconPosition.bottomLeft,
      ),
      OnboardingStep(
        id: 'drag_number',
        targetKey: _number3Key,
        destinationKey: _emptyCircleKey,
        title: 'Drag the Number',
        description: 'Drag',
        interactionType: InteractionType.dragDrop,
        hintIconColor: Colors.greenAccent,
        position: TooltipPosition.right,
        iconPosition: IconPosition.center,
      ),
    ];

    _onboardingController = OnboardingController(
      config: OnboardingConfig(
        steps: steps,
        tooltipConfig: const TooltipConfig(
          backgroundColor: Color(0xFF6750A4),
          textColor: Colors.white,
          maxWidth: 300,
        ),
        onComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Onboarding completed!')),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingOverlay(
      controller: _onboardingController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Math Game'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                _onboardingController.start();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildGameSelection(),
            Expanded(
              child: _buildMathGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Choose a Mini-game',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  key: _gameSelectionKey,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videogame_asset, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Math Game', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathGame() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            key: _mathProblemKey,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '2. Play, Learn and Earn Coins',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 32),
          _buildMathProblem(),
          const Spacer(),
          _buildNumberOptions(),
          const SizedBox(height: 16),
          _buildGameButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMathProblem() {
    return Container(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberCircle('10', Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberCircle('7', Colors.purple),
              const Text('+',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                key: _emptyCircleKey,
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDraggableNumber('3', Colors.blue, key: _number3Key),
        const SizedBox(width: 16),
        _buildNumberCircle('4', Colors.blue),
        const SizedBox(width: 16),
        _buildNumberCircle('2', Colors.blue),
      ],
    );
  }

  // Special method for the draggable number to avoid key conflicts
  Widget _buildDraggableNumber(String number, Color color, {Key? key}) {
    return Container(
      key: key,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCircle(String number, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGameButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              // Back button functionality
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              // Next button functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Moving to next question!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Next (3/5)'),
          ),
        ],
      ),
    );
  }
}
