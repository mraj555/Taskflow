import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskNotifier extends AsyncNotifier<List<Task>> {
  late final TaskRepository _repository;

  @override
  Future<List<Task>> build() async {
    _repository = ref.watch(taskRepositoryProvider);
    return await _repository.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.insertTask(task);
      state = AsyncValue.data(await _repository.getAllTasks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTask(task);
      state = AsyncValue.data(await _repository.getAllTasks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTask(id);
      state = AsyncValue.data(await _repository.getAllTasks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});
