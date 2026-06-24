import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  int _priority = 0; // 0: Low, 1: Medium, 2: High

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        ref.read(taskProvider.notifier).addTask(task);
      } else {
        ref.read(taskProvider.notifier).updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dueDate == null
                      ? 'Select Due Date'
                      : 'Due: ${DateFormat('MMM d, y').format(_dueDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                    child: const Text(
                      'Clear Date',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Low')),
                  ButtonSegment(value: 1, label: Text('Medium')),
                  ButtonSegment(value: 2, label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _priority = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Task', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
