
void main() {
  // Цілі числа
  int age = 18;
  int studentsCount = 25;

  // Числа з дробовою частиною
  double height = 1.90;
  double temperature = 22.5;

  // Тип num підтримує int і double
  num price = 199;
  price = 199.99;

  // Рядки
  String studentName = 'Denys';
  String courseName = 'Основи мови Dart';

  // Логічні значення
  bool isStudent = true;
  bool isGraduated = false;

  // Колекції
  List<String> subjects = [
    'Dart',
    'Flutter',
    'Мобільна розробка',
  ];

  Set<String> uniqueLanguages = {
    'Dart',
    'Java',
    'Python',
  };

  Map<String, int> grades = {
    'Dart': 95,
    'Flutter': 90,
    'Алгоритми': 88,
  };

  // Null safety
  String? optionalNickname;
  String displayedNickname = optionalNickname ?? 'Не вказано';

    // Математичні операції
  int a = 17;
  int b = 5;

  print('\n=== Математичні операції ===');
  print('Додавання: ${a + b}');
  print('Віднімання: ${a - b}');
  print('Множення: ${a * b}');
  print('Ділення: ${a / b}');
  print('Цілочисельне ділення: ${a ~/ b}');
  print('Остача від ділення: ${a % b}');

  // Перетворення типів
  double decimalNumber = 15.8;
  int integerNumber = decimalNumber.toInt();
  String numberAsText = integerNumber.toString();

  print('\n=== Перетворення типів ===');
  print('Double у int: $integerNumber');
  print('Число у String: $numberAsText');
  print('Рядок у double: ${double.parse('12.5')}');

  // Робота з рядками
  String firstName = 'Denys';
  String lastName = 'Klymenko';
  String fullName = '$firstName $lastName';
  String multilineText = '''
Це багаторядковий текст.
Він містить декілька рядків.
''';

  print('\n=== Робота з рядками ===');
  print('Повне ім’я: $fullName');
  print('Довжина імені: ${fullName.length}');
  print('Верхній регістр: ${fullName.toUpperCase()}');
  print('Нижній регістр: ${fullName.toLowerCase()}');
  print('Чи містить Dart? ${courseName.contains('Dart')}');
  print('Багаторядковий текст:$multilineText');
  print('Екранування символів: \'Dart\' та символ \\');

  // Логічні оператори та порівняння
  int studentAge = 18;
  bool hasPermission = true;

  print('\n=== Логічні оператори ===');
  print('Вік не менше 18: ${studentAge >= 18}');
  print('Дозвіл надано: $hasPermission');
  print('Можна продовжити: ${studentAge >= 18 && hasPermission}');
  print('Або одна з умов: ${studentAge < 18 || hasPermission}');
  print('Заперечення: ${!hasPermission}');

  // Умовний вираз
  String ageStatus = studentAge >= 18 ? 'Повнолітній' : 'Неповнолітній';
  print('Статус: $ageStatus');

  // Змінна late
  late String description;
  description = 'Змінну ініціалізовано перед використанням';
  print('\n=== Late ===');
  print(description);

  // Виведення результатів
  print('=== Базові типи Dart ===');
  print('Вік: $age');
  print('Кількість студентів: $studentsCount');
  print('Зріст: $height м');
  print('Температура: $temperature °C');
  print('Ціна: $price грн');
  print('Ім’я: $studentName');
  print('Дисципліна: $courseName');
  print('Студент: $isStudent');
  print('Випускник: $isGraduated');

  print('\n=== Колекції ===');
  print('Предмети: $subjects');
  print('Унікальні мови: $uniqueLanguages');
  print('Оцінки: $grades');

  print('\n=== Null safety ===');
  print('Псевдонім: $displayedNickname');
}
