import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

class CounterValue extends StatelessWidget {
  const CounterValue({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CounterValue');

    final value = CounterScope.of(context).value;

    return Text(
      '$value',
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
