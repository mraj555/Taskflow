import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../models/task.dart';
import '../../../models/category.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/category_provider.dart';
import '../screens/home_screen.dart';

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
  TimeOfDay? _dueTime;
  int _priority = 0; // 0: Low, 1: Medium, 2: High
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate;
    if (_dueDate != null) {
      _dueTime = TimeOfDay.fromDateTime(_dueDate!);
    }
    _priority = widget.task?.priority ?? 0;
    _selectedCategoryId = widget.task?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dueTime = pickedTime;
        });
      }
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
        categoryId: _selectedCategoryId,
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
    final categoryAsyncValue = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Hero(
          tag: widget.task?.id ?? 'add-task-hero',
          child: Material(
            color: Colors.transparent,
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
                  categoryAsyncValue.when(
                    data: (categories) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('No Category'),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Color(category.color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => const Text('Error loading categories'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _dueDate == null
                          ? 'Select Due Date & Time'
                          : 'Due: ${DateFormat('MMM d, y - h:mm a').format(_dueDate!)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDateTime,
                  ),
                  if (_dueDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                            _dueTime = null;
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
                    child: const Text(
                      'Save Task',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
