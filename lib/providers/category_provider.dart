import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<TaskCategory>>(() {
  return CategoryNotifier();
});

class CategoryNotifier extends AsyncNotifier<List<TaskCategory>> {
  @override
  Future<List<TaskCategory>> build() async {
    return _fetchCategories();
  }

  Future<List<TaskCategory>> _fetchCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    return repository.getAllCategories();
  }

  Future<void> addCategory(TaskCategory category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.insertCategory(category);
      return _fetchCategories();
    });
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.deleteCategory(id);
      return _fetchCategories();
    });
  }
}
