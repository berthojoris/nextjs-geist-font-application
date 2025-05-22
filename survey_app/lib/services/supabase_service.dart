import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/survey_response.dart';

class SupabaseService {
  late final SupabaseClient _client;
  
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() {
    return _instance;
  }
  
  SupabaseService._internal();

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: false,
      );
      _client = Supabase.instance.client;
      
      // Set device ID for RLS policies
      await _client.rpc('set_claim', params: {
        'claim': 'app.device_id',
        'value': SupabaseConfig.deviceId,
      });
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }

  Future<bool> syncResponse(SurveyResponse response) async {
    try {
      await _client
          .from('survey_responses')
          .insert({
            'id': response.id,
            'question_id': response.questionId,
            'answer': response.answer,
            'device_id': SupabaseConfig.deviceId,
            'timestamp': response.timestamp.toIso8601String(),
          });
      return true;
    } on PostgrestException catch (e) {
      print('Database error syncing response: ${e.message}');
      return false;
    } catch (e) {
      print('Error syncing response: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRemoteResponses() async {
    try {
      final response = await _client
          .from('survey_responses')
          .select()
          .eq('device_id', SupabaseConfig.deviceId)
          .order('timestamp', ascending: false)
          .execute();
      
      return (response.data as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      print('Database error fetching responses: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching remote responses: $e');
      return [];
    }
  }

  Future<bool> batchSyncResponses(List<SurveyResponse> responses) async {
    try {
      final data = responses.map((response) => {
        'id': response.id,
        'question_id': response.questionId,
        'answer': response.answer,
        'device_id': SupabaseConfig.deviceId,
        'timestamp': response.timestamp.toIso8601String(),
      }).toList();

      await _client
          .from('survey_responses')
          .insert(data);
      
      return true;
    } on PostgrestException catch (e) {
      print('Database error batch syncing responses: ${e.message}');
      return false;
    } catch (e) {
      print('Error batch syncing responses: $e');
      return false;
    }
  }

  Future<bool> isOnline() async {
    try {
      await _client.from('questions').select('id').limit(1).execute();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to check sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final localCount = await _client
          .from('survey_responses')
          .select('id')
          .eq('device_id', SupabaseConfig.deviceId)
          .execute();
      
      final syncedCount = await _client
          .from('survey_responses')
          .select('id')
          .eq('device_id', SupabaseConfig.deviceId)
          .eq('synced', true)
          .execute();

      return {
        'total': (localCount.data as List).length,
        'synced': (syncedCount.data as List).length,
      };
    } catch (e) {
      print('Error getting sync status: $e');
      return {'total': 0, 'synced': 0};
    }
  }
}
