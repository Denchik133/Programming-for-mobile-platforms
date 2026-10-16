
import 'package:pr4/models/course.dart';
import 'package:pr4/models/student.dart';
import 'package:test/test.dart';
import 'package:pr4/models/professor.dart';
import 'package:pr4/models/university.dart';

void main() {
  group('Student', () {
    late Student student;

    setUp(() {
      student = Student(
        id: 'S001',
        firstName: 'Denys',
        lastName: 'Klymenko',
        birthDate: DateTime(2008, 5, 10),
      );
    });

    test('правильно формує повне ім’я', () {
      expect(student.fullName, 'Denys Klymenko');
    });

    test('початковий середній бал дорівнює нулю', () {
      expect(student.gpa, 0.0);
    });

    test('обчислює середній бал', () {
      student.addGrade('Dart', 90);
      student.addGrade('Dart', 80);

      expect(student.gpa, 85.0);
    });

    test('відхиляє оцінки поза діапазоном', () {
      expect(() => student.addGrade('Dart', 120), throwsArgumentError);
      expect(() => student.addGrade('Dart', -1), throwsArgumentError);
    });

    test('не додає курс повторно', () {
      student.enrollInCourse('Dart');
      student.enrollInCourse('Dart');

      expect(student.enrolledCourses, ['Dart']);
    });

    test('визначає складені курси', () {
      student.addGrade('Dart', 80);
      student.addGrade('Flutter', 40);

      expect(student.getPassedCourses(), ['Dart']);
    });

    test('відновлює студента з JSON', () {
      student.enrollInCourse('Dart');
      student.addGrade('Dart', 90);

      final restored = Student.fromJson(student.toJson());

      expect(restored.id, student.id);
      expect(restored.fullName, student.fullName);
      expect(restored.enrolledCourses, ['Dart']);
      expect(restored.grades['Dart'], [90]);
      expect(restored.gpa, 90.0);
    });
  });

  group('Course', () {
    late Student student;
    late Course course;

    setUp(() {
      student = Student(
        id: 'S001',
        firstName: 'Denys',
        lastName: 'Klymenko',
        birthDate: DateTime(2008, 5, 10),
      );

      course = Course(
        id: 'C001',
        name: 'Flutter',
        description: 'Розробка мобільних застосунків',
        credits: 4,
        prerequisites: ['Dart'],
      );
    });

    test('створює курс із коректними параметрами', () {
      expect(course.name, 'Flutter');
      expect(course.credits, 4);
      expect(course.prerequisites, ['Dart']);
    });

    test('відхиляє нульову або від’ємну кількість кредитів', () {
      expect(
        () => Course(
          id: 'C002',
          name: 'Invalid',
          description: 'Некоректний курс',
          credits: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => Course(
          id: 'C003',
          name: 'Invalid',
          description: 'Некоректний курс',
          credits: -1,
        ),
        throwsArgumentError,
      );
    });

    test('дозволяє запис після складання передумови', () {
      student.addGrade('Dart', 80);

      expect(course.hasPrerequisites(student), isTrue);
      expect(course.canStudentEnroll(student), isTrue);
    });

    test('забороняє запис, якщо передумову не виконано', () {
      expect(course.hasPrerequisites(student), isFalse);
      expect(course.canStudentEnroll(student), isFalse);
    });

    test('забороняє повторний запис на курс', () {
      student.addGrade('Dart', 80);
      student.enrollInCourse('Flutter');

      expect(course.canStudentEnroll(student), isFalse);
    });

    test('дозволяє запис на курс без передумов', () {
      final introductoryCourse = Course(
        id: 'C004',
        name: 'Introduction to Programming',
        description: 'Вступ до програмування',
        credits: 3,
      );

      expect(introductoryCourse.canStudentEnroll(student), isTrue);
    });
  });


  group('Professor', () {
    late Professor professor;

    setUp(() {
      professor = Professor(
        id: 'P001',
        firstName: 'Oleksandr',
        lastName: 'Klymenko',
        birthDate: DateTime(1995, 3, 15),
        department: 'Software Engineering',
      );
    });

    test('зберігає ім’я та кафедру', () {
      expect(professor.fullName, 'Oleksandr Klymenko');
      expect(professor.department, 'Software Engineering');
    });

    test('повертає роль викладача', () {
      expect(professor.getRole(), 'Викладач');
    });

    test('додає курс до списку', () {
      professor.assignCourse('Dart');

      expect(professor.taughtCourses, ['Dart']);
    });

    test('не додає той самий курс повторно', () {
      professor.assignCourse('Dart');
      professor.assignCourse('Dart');

      expect(professor.taughtCourses, ['Dart']);
    });

    test('зберігає переданий список курсів', () {
      final professorWithCourses = Professor(
        id: 'P002',
        firstName: 'Anna',
        lastName: 'Shevchenko',
        birthDate: DateTime(1990, 7, 20),
        department: 'Computer Science',
        taughtCourses: ['Flutter', 'Dart'],
      );

      expect(
        professorWithCourses.taughtCourses,
        ['Flutter', 'Dart'],
      );
    });
  });


  group('University', () {
    late University university;
    late Student student;
    late Course course;

    setUp(() {
      university = University(name: 'Test University');

      student = Student(
        id: 'S001',
        firstName: 'Denys',
        lastName: 'Klymenko',
        birthDate: DateTime(2008, 5, 10),
      );

      course = Course(
        id: 'C001',
        name: 'Dart',
        description: 'Основи Dart',
        credits: 4,
      );
    });

    test('додає студента, викладача та курс', () {
      university.addStudent(student);

      university.addProfessor(
        Professor(
          id: 'P001',
          firstName: 'Oleksandr',
          lastName: 'Klymenko',
          birthDate: DateTime(1995, 3, 15),
          department: 'Software Engineering',
        ),
      );

      university.addCourse(course);

      expect(university.students.length, 1);
      expect(university.professors.length, 1);
      expect(university.courses.length, 1);
    });

    test('забороняє додавання студента з повторним ID', () {
      university.addStudent(student);

      expect(
        () => university.addStudent(student),
        throwsArgumentError,
      );
    });

    test('знаходить студента за ID', () {
      university.addStudent(student);

      expect(university.findStudentById('S001'), same(student));
      expect(university.findStudentById('unknown'), isNull);
    });

    test('записує студента на курс', () {
      university.addStudent(student);
      university.addCourse(course);

      final result = university.enrollStudent('S001', 'C001');

      expect(result, isTrue);
      expect(student.enrolledCourses, ['Dart']);
    });

    test('відхиляє запис неіснуючого студента', () {
      university.addCourse(course);

      expect(university.enrollStudent('unknown', 'C001'), isFalse);
    });

    test('відхиляє повторний запис на курс', () {
      university.addStudent(student);
      university.addCourse(course);

      expect(university.enrollStudent('S001', 'C001'), isTrue);
      expect(university.enrollStudent('S001', 'C001'), isFalse);
    });

    test('повертає студентів, записаних на курс', () {
      university.addStudent(student);
      university.addCourse(course);
      university.enrollStudent('S001', 'C001');

      expect(
        university.getStudentsByCourse('Dart'),
        [same(student)],
      );
    });

    test('формує статистику університету', () {
      university.addStudent(student);
      student.addGrade('Dart', 90);

      university.addCourse(course);

      final statistics = university.generateStatistics();

      expect(statistics['university'], 'Test University');
      expect(statistics['studentsCount'], 1);
      expect(statistics['professorsCount'], 0);
      expect(statistics['coursesCount'], 1);
      expect(statistics['averageGpa'], 90.0);
    });
  });
}
