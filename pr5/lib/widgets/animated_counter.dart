import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 10,
    super.key,
  })  : assert(minValue <= initialValue),
        assert(initialValue <= maxValue);

  final int initialValue;
  final int minValue;
  final int maxValue;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late int _value;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.deepPurple,
      end: Colors.orange,
    ).animate(_controller);
  }

  void _changeValue(int delta) {
    final nextValue = (_value + delta).clamp(
      widget.minValue,
      widget.maxValue,
    );

    if (nextValue == _value) return;

    setState(() {
      _value = nextValue;
    });

    _controller.forward(from: 0).then((_) {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Animated Counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Зменшити',
                  onPressed:
                      _value > widget.minValue ? () => _changeValue(-1) : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return Text(
                        '$_value',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                          color: _colorAnimation.value,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                IconButton.filledTonal(
                  tooltip: 'Збільшити',
                  onPressed:
                      _value < widget.maxValue ? () => _changeValue(1) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Межі: ${widget.minValue}–${widget.maxValue}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}