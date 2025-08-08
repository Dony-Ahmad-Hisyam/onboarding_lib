import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

class MathGameDemo extends StatefulWidget {
  const MathGameDemo({Key? key}) : super(key: key);

  @override
  State<MathGameDemo> createState() => _MathGameDemoState();
}

class _MathGameDemoState extends State<MathGameDemo> {
  late OnboardingController _onboardingController;

  // Tap targets
  final GlobalKey _gameSelectionKey = GlobalKey(debugLabel: 'gameSelectionKey');
  final GlobalKey _mathProblemKey = GlobalKey(debugLabel: 'mathProblemKey');
  final GlobalKey _onNextKey = GlobalKey(debugLabel: 'onNextKey');

  // Drag sources
  final GlobalKey _src3Key = GlobalKey(debugLabel: 'src_3');
  final GlobalKey _src4Key = GlobalKey(debugLabel: 'src_4');
  final GlobalKey _src2Key = GlobalKey(debugLabel: 'src_2');

  // Drag destinations
  final GlobalKey _dstEmptyKey = GlobalKey(debugLabel: 'dst_empty');
  final GlobalKey _dst7Key = GlobalKey(debugLabel: 'dst_7');
  final GlobalKey _dst10Key = GlobalKey(debugLabel: 'dst_10');

  // Drag-drop progress (generic)
  String? _valueInEmpty; // for dst_empty
  String? _valueOnSeven; // for dst_7
  String? _valueOnTen; // for dst_10

  @override
  void initState() {
    super.initState();
    _initOnboarding();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _onboardingController.start();
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
      // Drag 3 -> empty
      dragStep(
        id: 'drag_number1',
        sourceKey: _src3Key,
        destinationKey: _dstEmptyKey,
        title: 'Drag the Number',
        description:
            'Drag the number from here to the empty circle to complete the equation.',
      ),
      // Drag 2 -> 7
      dragStep(
        id: 'drag_number2',
        sourceKey: _src2Key,
        destinationKey: _dst7Key,
        title: 'Drag the Number',
        description: 'Drag the correct number into the circle.',
      ),
      // Drag 4 -> 10
      dragStep(
        id: 'drag_number3',
        sourceKey: _src4Key,
        destinationKey: _dst10Key,
        title: 'Drag the Number',
        description: 'Drag the correct number into the circle.',
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
            onPressed: () => _onboardingController.start(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGameSelection(),
          Expanded(child: _buildMathGame()),
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
                Text('1. Choose a Mini-game',
                    style: Theme.of(context).textTheme.titleLarge),
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
            child: Text('2. Play, Learn and Earn Coins',
                style: Theme.of(context).textTheme.titleLarge),
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
              // Destination 10
              DragTarget<String>(
                key: _dst10Key,
                onWillAccept: (d) => d == '4' && _valueOnTen == null,
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
              // Destination 7
              DragTarget<String>(
                key: _dst7Key,
                onWillAccept: (d) => d == '2' && _valueOnSeven == null,
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
              // Destination empty
              DragTarget<String>(
                key: _dstEmptyKey,
                onWillAccept: (d) => d == '3' && _valueInEmpty == null,
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
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Source 3
        Builder(builder: (context) {
          final number = '3';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueInEmpty == null;
          return enabled
              ? Draggable<String>(
                  key: _src3Key,
                  data: number,
                  child: circle,
                  childWhenDragging: Opacity(opacity: 0.2, child: circle),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circle);
        }),
        const SizedBox(width: 16),
        // Source 4
        Builder(builder: (context) {
          final number = '4';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueOnTen == null;
          return enabled
              ? Draggable<String>(
                  key: _src4Key,
                  data: number,
                  child: circle,
                  childWhenDragging: Opacity(opacity: 0.2, child: circle),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circle);
        }),
        const SizedBox(width: 16),
        // Source 2
        Builder(builder: (context) {
          final number = '2';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueOnSeven == null;
          return enabled
              ? Draggable<String>(
                  key: _src2Key,
                  data: number,
                  child: circle,
                  childWhenDragging: Opacity(opacity: 0.2, child: circle),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circle);
        }),
      ],
    );
  }

  Widget _buildGameButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Back'),
          ),
          ElevatedButton(
            key: _onNextKey,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Moving to next question!')));
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
