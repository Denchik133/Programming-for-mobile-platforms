import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/assignment.dart';
import '../utils/grade_calculator.dart';
import 'assignment_form_screen.dart';
import 'attendance_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final courseId = widget.course['id'] as int;
    final db = DatabaseHelper.instance;

    final assignmentMaps = await db.getAssignments(courseId);
    final attendance = await db.getAttendanceStatistics(courseId);

    final assignments = assignmentMaps
        .map((map) => Assignment.fromMap(map))
        .toList();

    return {'assignments': assignments, 'attendance': attendance};
  }

  Future<void> _refreshData() async {
    final newFuture = _loadData();

    setState(() {
      _dataFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openAssignmentForm({Map<String, dynamic>? assignment}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentFormScreen(
          courseId: widget.course['id'] as int,
          assignment: assignment,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshData();
    }
  }

  Future<void> _openAttendance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(
          courseId: widget.course['id'] as int,
          courseName: widget.course['name'].toString(),
        ),
      ),
    );

    if (mounted) {
      await _refreshData();
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteAssignment(assignment.id!);

      if (!mounted) return;

      await _refreshData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete assignment: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course['name'].toString()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAssignmentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Assignment'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading course: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final assignments = data['assignments'] as List<Assignment>;
          final attendance = data['attendance'] as Map<String, int>;

          final average = GradeCalculator.calculateWeightedAverage(assignments);

          final gpa = GradeCalculator.calculateGpa(average);

          final statistics = GradeCalculator.calculateStatistics(assignments);

          final targetGrade = (course['target_grade'] as num).toDouble();

          final requiredScore = GradeCalculator.calculateRequiredScore(
            assignments: assignments,
            targetGrade: targetGrade,
          );

          final completion = (statistics['completionPercentage'] as num)
              .toDouble();

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                _buildSectionTitle('Course Information'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['name'].toString(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Course code', course['code'].toString()),
                        _buildInfoRow(
                          'Instructor',
                          course['instructor'].toString(),
                        ),
                        _buildInfoRow('Credits', '${course['credits']}'),
                        _buildInfoRow(
                          'Target grade',
                          '${targetGrade.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildSectionTitle('Academic Performance'),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Average Grade',
                        '${average.toStringAsFixed(1)}%',
                        Icons.grade,
                        Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'GPA',
                        gpa.toStringAsFixed(2),
                        Icons.school,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildSectionTitle('Assignment Progress'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Total assignments',
                          '${statistics['totalAssignments']}',
                        ),
                        _buildInfoRow(
                          'Completed',
                          '${statistics['completedAssignments']}',
                        ),
                        _buildInfoRow(
                          'Pending',
                          '${statistics['pendingAssignments']}',
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: completion / 100,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 8),
                        Text('${completion.toStringAsFixed(1)}% completed'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildSectionTitle('Target Grade Calculator'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Desired grade',
                          '${targetGrade.toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 8),
                        if (requiredScore == null)
                          const Text(
                            'There are no remaining assignments '
                            'to calculate the required score.',
                          )
                        else if (requiredScore <= 0)
                          const Text(
                            'You have already achieved your target grade.',
                            style: TextStyle(color: Colors.green),
                          )
                        else if (requiredScore > 100)
                          const Text(
                            'The target grade is no longer achievable.',
                            style: TextStyle(color: Colors.red),
                          )
                        else
                          Text(
                            'Required average on remaining assignments: '
                            '${requiredScore.toStringAsFixed(1)}%',
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildSectionTitle('Assignments'),
                if (assignments.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('No assignments available.'),
                      subtitle: Text(
                        'Press Add Assignment to create your first task.',
                      ),
                    ),
                  )
                else
                  ...assignments.map((assignment) {
                    final score = assignment.earnedScore;
                    final hasScore = score != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () async {
                          final assignmentMap = await DatabaseHelper.instance
                              .getAssignmentById(assignment.id!);

                          if (assignmentMap != null && mounted) {
                            await _openAssignmentForm(
                              assignment: assignmentMap,
                            );
                          }
                        },
                        leading: Icon(
                          hasScore ? Icons.check_circle : Icons.pending,
                          color: hasScore ? Colors.green : Colors.orange,
                        ),
                        title: Text(assignment.name),
                        subtitle: Text(
                          '${assignment.type} • '
                          'Weight: ${assignment.weight}%\n'
                          'Due: ${assignment.dueDate}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasScore
                                  ? '${score.toStringAsFixed(1)} / '
                                        '${assignment.maxScore.toStringAsFixed(1)}'
                                  : 'Pending',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final assignmentMap = await DatabaseHelper
                                      .instance
                                      .getAssignmentById(assignment.id!);

                                  if (assignmentMap != null && mounted) {
                                    await _openAssignmentForm(
                                      assignment: assignmentMap,
                                    );
                                  }
                                } else if (value == 'delete') {
                                  await _deleteAssignment(assignment);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // ATTENDANCE MANAGEMENT
                _buildSectionTitle('Attendance Management'),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.event_available),
                    ),
                    title: const Text('Manage Attendance'),
                    subtitle: Text(
                      '${attendance['present']} present, '
                      '${attendance['absent']} absent, '
                      '${attendance['late']} late',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _openAttendance,
                  ),
                ),

                const SizedBox(height: 20),

                _buildSectionTitle('Attendance Statistics'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Total classes',
                          '${attendance['total']}',
                        ),
                        _buildInfoRow('Present', '${attendance['present']}'),
                        _buildInfoRow('Absent', '${attendance['absent']}'),
                        _buildInfoRow('Late', '${attendance['late']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
