import '../models/assignment.dart';

class GradeCalculator {
  /// Обчислює зважену оцінку за курсом у відсотках.
  ///
  /// Враховуються лише завдання, для яких уже введено отриманий бал.
  static double calculateWeightedAverage(List<Assignment> assignments) {
    double totalWeightedScore = 0;
    double totalWeight = 0;

    for (final assignment in assignments) {
      if (assignment.earnedScore == null) {
        continue;
      }

      if (assignment.maxScore <= 0 || assignment.weight <= 0) {
        continue;
      }

      final percentage = (assignment.earnedScore! / assignment.maxScore) * 100;

      totalWeightedScore += percentage * assignment.weight;
      totalWeight += assignment.weight;
    }

    if (totalWeight == 0) {
      return 0;
    }

    return totalWeightedScore / totalWeight;
  }

  /// Перетворює відсоткову оцінку на GPA за шкалою 4.0.
  static double calculateGpa(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 85) return 3.7;
    if (percentage >= 80) return 3.3;
    if (percentage >= 75) return 3.0;
    if (percentage >= 70) return 2.7;
    if (percentage >= 65) return 2.3;
    if (percentage >= 60) return 2.0;
    if (percentage >= 55) return 1.7;
    if (percentage >= 50) return 1.0;
    return 0.0;
  }

  static double? calculateRequiredScore({
    required List<Assignment> assignments,
    required double targetGrade,
  }) {
    double earnedWeightedScore = 0;
    double completedWeight = 0;
    double remainingWeight = 0;

    for (final assignment in assignments) {
      if (assignment.weight <= 0 || assignment.maxScore <= 0) {
        continue;
      }

      if (assignment.earnedScore != null) {
        final percentage =
            (assignment.earnedScore! / assignment.maxScore) * 100;

        earnedWeightedScore += percentage * assignment.weight;
        completedWeight += assignment.weight;
      } else {
        remainingWeight += assignment.weight;
      }
    }

    if (remainingWeight <= 0) {
      return null;
    }

    final requiredScore =
        (targetGrade * (completedWeight + remainingWeight) -
            earnedWeightedScore) /
        remainingWeight;

    return requiredScore;
  }

  /// Повертає статистику виконання завдань.
  static Map<String, dynamic> calculateStatistics(
    List<Assignment> assignments,
  ) {
    final totalAssignments = assignments.length;

    final completedAssignments = assignments
        .where((assignment) => assignment.earnedScore != null)
        .length;

    final pendingAssignments = totalAssignments - completedAssignments;

    final average = calculateWeightedAverage(assignments);

    return {
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'pendingAssignments': pendingAssignments,
      'completionPercentage': totalAssignments == 0
          ? 0.0
          : completedAssignments / totalAssignments * 100,
      'weightedAverage': average,
      'gpa': calculateGpa(average),
    };
  }
}
