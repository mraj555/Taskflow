import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();

  factory SyncService() {
    return _instance;
  }

  SyncService._internal();

  final bool _isConfigured = false; // Set to true after adding valid keys
  final String _supabaseUrl = 'https://tokldsyygzsmnijvrhpt.supabase.co';
  final String _supabaseAnonKey =
      'sb_publishable_MZo20QokEKxjZM0l9qUAOg_NJUJokLC';

  Future<void> init() async {
    if (_isConfigured) {
      await Supabase.initialize(
        url: _supabaseUrl,
        publishableKey: _supabaseAnonKey,
      );
    } else {
      print(
        'SyncService: Supabase is not configured. Mocking sync operations.',
      );
    }
  }

  SupabaseClient? get _client =>
      _isConfigured ? Supabase.instance.client : null;

  Future<void> pushTask(Task task) async {
    if (!_isConfigured) {
      print('SyncService (Mock): Pushing task ${task.title} to cloud.');
      return;
    }

    try {
      await _client!.from('tasks').upsert(task.toMap());
    } catch (e) {
      print('Error syncing task to cloud: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    if (!_isConfigured) {
      print('SyncService (Mock): Deleting task $id from cloud.');
      return;
    }

    try {
      await _client!.from('tasks').delete().eq('id', id);
    } catch (e) {
      print('Error deleting task from cloud: $e');
    }
  }
}
