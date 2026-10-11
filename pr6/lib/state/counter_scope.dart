import 'package:flutter/widgets.dart';

import 'counter_state.dart';

class CounterScope extends InheritedNotifier<CounterState> {
  const CounterScope({
    super.key,
    required CounterState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static CounterState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CounterScope>();

    assert(scope != null, 'CounterScope not found in widget tree');

    return scope!.notifier!;
  }

  static CounterState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<CounterScope>();
    final scope = element?.widget as CounterScope?;

    assert(scope != null, 'CounterScope not found in widget tree');

    return scope!.notifier!;
  }
}
