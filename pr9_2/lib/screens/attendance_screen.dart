import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class AttendanceScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const AttendanceScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Map<String, dynamic>>> _attendanceFuture;
  late Future<Map<String, int>> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _attendanceFuture = DatabaseHelper.instance.getAttendance(widget.courseId);

    _statisticsFuture = DatabaseHelper.instance.getAttendanceStatistics(
      widget.courseId,
    );
  }

  Future<void> _refreshData() async {
    setState(_loadData);
    await Future.wait([_attendanceFuture, _statisticsFuture]);
  }

  String _formatDate(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;

    return '${parsed.day.toString().padLeft(2, '0')}.'
        '${parsed.month.toString().padLeft(2, '0')}.'
        '${parsed.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      default:
        return status;
    }
  }

  Future<void> _showAttendanceForm({Map<String, dynamic>? attendance}) async {
    final dateController = TextEditingController(
      text:
          attendance?['date']?.toString() ??
          DateTime.now().toIso8601String().substring(0, 10),
    );

    String selectedStatus = attendance?['status']?.toString() ?? 'present';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                attendance == null ? 'Add Attendance' : 'Edit Attendance',
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final initialDate =
                            DateTime.tryParse(dateController.text) ??
                            DateTime.now();

                        final selectedDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: initialDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate != null) {
                          dateController.text = selectedDate
                              .toIso8601String()
                              .substring(0, 10);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Attendance Status',
                        prefixIcon: Icon(Icons.event_available),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'present',
                          child: Text('Present'),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Text('Absent'),
                        ),
                        DropdownMenuItem(value: 'late', child: Text('Late')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (dateController.text.isEmpty ||
                        DateTime.tryParse(dateController.text) == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Select a valid date.')),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      dateController.dispose();
      return;
    }

    try {
      final data = {
        'course_id': widget.courseId,
        'date': dateController.text,
        'status': selectedStatus,
      };

      if (attendance == null) {
        await DatabaseHelper.instance.insertAttendance(data);
      } else {
        await DatabaseHelper.instance.updateAttendance(
          attendance['id'] as int,
          data,
        );
      }

      if (!mounted) return;

      await _refreshData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            attendance == null
                ? 'Attendance added successfully.'
                : 'Attendance updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attendance: $error')),
      );
    } finally {
      dateController.dispose();
    }
  }

  Future<void> _deleteAttendance(Map<String, dynamic> attendance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text(
          'Are you sure you want to delete this attendance record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteAttendance(attendance['id'] as int);

      if (!mounted) return;

      await _refreshData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete attendance: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAttendanceForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Attendance'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            Text(
              widget.courseName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // ATTENDANCE STATISTICS
            const Text(
              'Attendance Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<Map<String, int>>(
              future: _statisticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final stats = snapshot.data!;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            '${stats['total']}',
                            Icons.event,
                            Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Present',
                            '${stats['present']}',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Absent',
                            '${stats['absent']}',
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Late',
                            '${stats['late']}',
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAttendancePercentage(stats),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ATTENDANCE HISTORY
            const Text(
              'Attendance History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No attendance records yet. '
                        'Press Add Attendance to create one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: records.map((record) {
                    final status = record['status'].toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _statusIcon(status),
                          color: _statusColor(status),
                        ),
                        title: Text(_formatDate(record['date'].toString())),
                        subtitle: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAttendanceForm(attendance: record);
                            } else if (value == 'delete') {
                              _deleteAttendance(record);
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
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendancePercentage(Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final present = stats['present'] ?? 0;

    final percentage = total == 0 ? 0.0 : present / total * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Rate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
