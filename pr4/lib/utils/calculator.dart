
class Calculator {
  static double add(double a, double b) => a + b;

  static double subtract(double a, double b) => a - b;

  static double multiply(double a, double b) => a * b;

  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Ділення на нуль неможливе');
    }

    return a / b;
  }

  static double calculateAverage(List<num> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('Список чисел не може бути порожнім');
    }

    final sum = numbers.fold<num>(0, (total, number) => total + number);
    return sum / numbers.length;
  }
}
