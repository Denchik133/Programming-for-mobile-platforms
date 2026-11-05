import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class AssignmentFormScreen extends StatefulWidget {
  final int courseId;
  final Map<String, dynamic>? assignment;

  const AssignmentFormScreen({
    super.key,
    required this.courseId,
    this.assignment,
  });

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _earnedScoreController;

  String _selectedType = 'Homework';
  DateTime _dueDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.assignment != null;

  static const List<String> _assignmentTypes = [
    'Homework',
    'Project',
    'Exam',
    'Quiz',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final assignment = widget.assignment;

    _nameController = TextEditingController(
      text: assignment?['name']?.toString() ?? '',
    );

    _weightController = TextEditingController(
      text: assignment?['weight']?.toString() ?? '',
    );

    _maxScoreController = TextEditingController(
      text: assignment?['max_score']?.toString() ?? '100',
    );

    _earnedScoreController = TextEditingController(
      text: assignment?['earned_score']?.toString() ?? '',
    );

    final type = assignment?['type']?.toString();

    if (type != null && _assignmentTypes.contains(type)) {
      _selectedType = type;
    }

    final date = assignment?['due_date']?.toString();

    if (date != null) {
      _dueDate = DateTime.tryParse(date) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _maxScoreController.dispose();
    _earnedScoreController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  String? _validatePositiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');

    if (number == null || !number.isFinite || number <= 0) {
      return 'Enter a number greater than 0';
    }

    return null;
  }

  String? _validateWeight(String? value) {
    final number = double.tryParse(value?.trim() ?? '');

    if (number == null || !number.isFinite || number <= 0 || number > 100) {
      return 'Enter a weight between 0 and 100';
    }

    return null;
  }

  String? _validateEarnedScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final earned = double.tryParse(value.trim());
    final maximum = double.tryParse(_maxScoreController.text.trim());

    if (earned == null || !earned.isFinite || earned < 0) {
      return 'Enter a valid score';
    }

    if (maximum != null && earned > maximum) {
      return 'Score cannot exceed maximum';
    }

    return null;
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final data = <String, dynamic>{
      'course_id': widget.courseId,
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'weight': double.parse(_weightController.text.trim()),
      'max_score': double.parse(_maxScoreController.text.trim()),
      'earned_score': _earnedScoreController.text.trim().isEmpty
          ? null
          : double.parse(_earnedScoreController.text.trim()),
      'due_date': _dueDate.toIso8601String().substring(0, 10),
    };

    try {
      final db = DatabaseHelper.instance;

      if (_isEditing) {
        await db.updateAssignment(widget.assignment!['id'] as int, data);
      } else {
        await db.insertAssignment(data);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save assignment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Assignment Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter assignment name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Assignment Type',
                border: OutlineInputBorder(),
              ),
              items: _assignmentTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Weight (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
              ),
              validator: _validateWeight,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _maxScoreController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Maximum Score',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.score),
              ),
              validator: _validatePositiveNumber,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _earnedScoreController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Earned Score (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
              ),
              validator: _validateEarnedScore,
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.year}-'
                  '${_dueDate.month.toString().padLeft(2, '0')}-'
                  '${_dueDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _isSaving ? null : _saveAssignment,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
