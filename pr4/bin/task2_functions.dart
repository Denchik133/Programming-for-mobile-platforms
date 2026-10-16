
double calculateSum(List<double> numbers) {
  return numbers.fold(0.0, (sum, number) => sum + number);
}

double calculateAverage(List<double> numbers) {
  if (numbers.isEmpty) {
    return 0.0;
  }

  return calculateSum(numbers) / numbers.length;
}

String formatName(
  String firstName, {
  String? middleName,
  String? lastName,
  bool uppercase = false,
}) {
  final parts = [
    firstName,
    if (middleName != null && middleName.isNotEmpty) middleName,
    if (lastName != null && lastName.isNotEmpty) lastName,
  ];

  final fullName = parts.join(' ');
  return uppercase ? fullName.toUpperCase() : fullName;
}

int factorial(int number) {
  if (number < 0) {
    throw ArgumentError('Число не може бути від’ємним');
  }

  if (number <= 1) {
    return 1;
  }

  return number * factorial(number - 1);
}

int fibonacci(int number) {
  if (number < 0) {
    throw ArgumentError('Число не може бути від’ємним');
  }

  if (number <= 1) {
    return number;
  }

  return fibonacci(number - 1) + fibonacci(number - 2);
}

Function(int) createMultiplier(int multiplier) {
  return (int number) => number * multiplier;
}

void main() {
  final numbers = [10.0, 20.0, 30.0, 40.0, 50.0];

  print('=== Звичайні функції ===');
  print('Сума: ${calculateSum(numbers)}');
  print('Середнє значення: ${calculateAverage(numbers)}');

  print('\n=== Іменовані параметри ===');
  print('Звичайне ім’я: ${formatName('Denys', lastName: 'Klymenko')}');
  print(
    'Повне ім’я: ${formatName(
      'Denys',
      middleName: 'Oleksandrovych',
      lastName: 'Klymenko',
    )}',
  );
  print(
    'Верхній регістр: ${formatName(
      'Denys',
      lastName: 'Klymenko',
      uppercase: true,
    )}',
  );

  print('\n=== Анонімна функція ===');
  final squaredNumbers = numbers.map((number) => number * number).toList();
  print('Квадрати чисел: $squaredNumbers');

  print('\n=== Фільтрація колекції ===');
  final evenNumbers = [1, 2, 3, 4, 5, 6]
      .where((number) => number.isEven)
      .toList();
  print('Парні числа: $evenNumbers');

  print('\n=== Згортання колекції ===');
  final total = [1, 2, 3, 4, 5].fold(
    0,
    (sum, number) => sum + number,
  );
  print('Сума чисел від 1 до 5: $total');

  print('\n=== Замикання ===');
  final multiplyByThree = createMultiplier(3);
  print('3 × 5 = ${multiplyByThree(5)}');
  print('3 × 10 = ${multiplyByThree(10)}');

  print('\n=== Рекурсія ===');
  print('Факторіал 5: ${factorial(5)}');
  print('Число Фібоначчі з індексом 7: ${fibonacci(7)}');
}
