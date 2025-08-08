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
  final GlobalKey _onNextKey = GlobalKey(debugLabel: 'onNextKey');
  final GlobalKey _number2Key = GlobalKey(debugLabel: 'number2Key');
  final GlobalKey _number4Key = GlobalKey(debugLabel: 'number4Key');
  final GlobalKey _destination2Key = GlobalKey(debugLabel: 'destination2Key');
  final GlobalKey _destination4Key = GlobalKey(debugLabel: 'destination4Key');

// Drag-drop progress
  String? _valueInEmpty; // 3 -> empty circle
  String? _valueOnSeven; // 2 -> 7
  String? _valueOnTen; // 4 -> 10

  @override
  void initState() {
    super.initState();
    _initOnboarding();

    // Start onboarding after a longer delay to ensure all widgets are properly laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _onboardingController.start();
        }
      });
    });
  }

  void _initOnboarding() {
    final steps = [
      tapStep(
        id: 'select_game',
        targetKey: _gameSelectionKey,
        title: 'Choose a Mini-game',
        description:
            'Tap on this game selector to start playing and learning math concepts. This is your first step!',
      ),
      tapStep(
        id: 'math_problem',
        targetKey: _mathProblemKey,
        title: 'Play, Learn and Earn Coins',
        description:
            'This section shows your current math problem. Solve math problems to earn coins and progress through the levels.',
      ),
      dragStep(
        id: 'drag_number1',
        sourceKey: _number3Key,
        destinationKey: _emptyCircleKey,
        title: 'Drag the Number',
        description:
            'Drag the number "3" from here to the empty circle to complete the math equation 7 + 3 = 10',
      ),
      dragStep(
        id: 'drag_number2',
        sourceKey: _number2Key,
        destinationKey: _destination2Key,
        title: 'Drag the Number',
        description:
            'Drag the number "2" from here to the empty circle to complete the math equation 7 + 2 = 9',
      ),
      dragStep(
        id: 'drag_number3',
        sourceKey: _number4Key,
        destinationKey: _destination4Key,
        title: 'Drag the Number',
        description:
            'Drag the number "4" from here to the empty circle to complete the math equation 7 + 4 = 11',
      ),
      tapStep(
        id: 'on_next',
        targetKey: _onNextKey,
        title: 'Next Steps',
        description:
            'Tap on the "Next" button to move to the next math problem and continue your learning journey.',
        position: TooltipPosition.top,
      ),
    ];

    _onboardingController = ob(
      steps: steps,
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding completed! Great job!')),
        );
      },
    );
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    ).withOnboarding(_onboardingController);
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
              ObDragTarget<String>(
                keyRef: _destination4Key,
                canAccept: (d) => d == '4' && _valueOnTen == null,
                onAccept: (d) => setState(() => _valueOnTen = d),
                builder: (context, cand, _) {
                  final color = _valueOnTen != null
                      ? Colors.green
                      : (cand.isNotEmpty
                          ? Colors.purple.shade700
                          : Colors.purple);
                  return _buildNumberCircle('10', color);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ObDragTarget<String>(
                keyRef: _destination2Key,
                canAccept: (d) => d == '2' && _valueOnSeven == null,
                onAccept: (d) => setState(() => _valueOnSeven = d),
                builder: (context, cand, _) {
                  final color = _valueOnSeven != null
                      ? Colors.green
                      : (cand.isNotEmpty
                          ? Colors.purple.shade700
                          : Colors.purple);
                  return _buildNumberCircle('7', color);
                },
              ),
              const Text('+',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ObDragTarget<String>(
                keyRef: _emptyCircleKey,
                canAccept: (d) => d == '3' && _valueInEmpty == null,
                onAccept: (d) => setState(() => _valueInEmpty = d),
                builder: (context, cand, _) {
                  final highlight = cand.isNotEmpty;
                  final hasValue = _valueInEmpty != null;
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: hasValue ? Colors.purple : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            highlight ? Colors.purple.shade700 : Colors.purple,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        hasValue ? _valueInEmpty! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
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
        _buildDraggableNumber('3', Colors.blue,
            keyRef: _number3Key, enabled: _valueInEmpty == null),
        const SizedBox(width: 16),
        _buildDraggableNumber('4', Colors.blue,
            keyRef: _number4Key, enabled: _valueOnTen == null),
        const SizedBox(width: 16),
        _buildDraggableNumber('2', Colors.blue,
            keyRef: _number2Key, enabled: _valueOnSeven == null),
      ],
    );
  }

  // Special method for the draggable number to avoid key conflicts
  Widget _buildDraggableNumber(String number, Color color,
      {required GlobalKey keyRef, bool enabled = true}) {
    final circle = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final fb = Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    if (!enabled) return Opacity(opacity: 0.4, child: circle);

    return ObDraggable<String>(
      keyRef: keyRef,
      data: number,
      child: circle,
      childWhenDragging: Opacity(opacity: 0.2, child: circle),
      feedback: fb,
    );
  }

  Widget _buildNumberCircle(String number, Color color, {Key? key}) {
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
            key: _onNextKey,
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
