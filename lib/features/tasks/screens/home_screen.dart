import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  int _filterStatus = 0; // 0: All, 1: Pending, 2: Completed

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterStatus == 0,
                      onSelected: (_) => setState(() => _filterStatus = 0),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _filterStatus == 1,
                      onSelected: (_) => setState(() => _filterStatus = 1),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Completed'),
                      selected: _filterStatus == 2,
                      onSelected: (_) => setState(() => _filterStatus = 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: tasksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (tasks) {
          // Apply filters and search
          final filteredTasks = tasks.where((task) {
            final matchesSearch = task.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchesFilter =
                _filterStatus == 0 ||
                (_filterStatus == 1 && !task.isCompleted) ||
                (_filterStatus == 2 && task.isCompleted);
            return matchesSearch && matchesFilter;
          }).toList();

          // Sort: pending first, then by priority (High to Low)
          filteredTasks.sort((a, b) {
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            return b.priority.compareTo(a.priority);
          });

          if (filteredTasks.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskTile(
                task: task,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(task: task),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
