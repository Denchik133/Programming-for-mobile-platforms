
import 'package:pr4/utils/calculator.dart';
import 'package:pr4/utils/data_processor.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    test('додає числа', () {
      expect(Calculator.add(10, 5), 15.0);
    });

    test('віднімає числа', () {
      expect(Calculator.subtract(10, 5), 5.0);
    });

    test('множить числа', () {
      expect(Calculator.multiply(10, 5), 50.0);
    });

    test('ділить числа', () {
      expect(Calculator.divide(10, 5), 2.0);
    });

    test('обробляє ділення на нуль', () {
      expect(() => Calculator.divide(10, 0), throwsArgumentError);
    });

    test('обчислює середнє значення', () {
      expect(Calculator.calculateAverage([10, 20, 30]), 20.0);
    });

    test('відхиляє порожній список', () {
      expect(
        () => Calculator.calculateAverage([]),
        throwsArgumentError,
      );
    });
  });

  group('DataProcessor', () {
    test('фільтрує парні числа', () {
      expect(
        DataProcessor.filterEvenNumbers([1, 2, 3, 4, 5, 6]),
        [2, 4, 6],
      );
    });

    test('підраховує слова без урахування регістру', () {
      expect(
        DataProcessor.countWords('Dart Flutter Dart'),
        {'dart': 2, 'flutter': 1},
      );
    });
  });
}
