import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/survey_response.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../services/logger_service.dart';
import '../utils/app_utils.dart';

class SurveyProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final _uuid = const Uuid();

  List<Question> _questions = [];
  Map<String, dynamic> _responses = {};
  bool _isLoading = true;
  bool _isSyncing = false;
  int _currentQuestionIndex = 0;

  // Getters
  List<Question> get questions => _questions;
  Map<String, dynamic> get responses => _responses;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => _questions[_currentQuestionIndex];
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  double get progress => _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;

  // Initialize the survey
  Future<void> initializeSurvey() async {
    try {
      _isLoading = true;
      notifyListeners();

      _questions = await HiveService.getAllQuestions();
      
      // Load any saved responses
      final savedResponses = await HiveService.getAllResponses();
      for (var response in savedResponses) {
        _responses[response.questionId] = response.answer;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Error initializing survey', e, stackTrace);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Save response for current question
  Future<void> saveResponse(String questionId, dynamic answer) async {
    try {
      final response = SurveyResponse(
        id: _uuid.v4(),
        questionId: questionId,
        answer: answer,
      );

      await HiveService.saveResponse(response);
      
      _responses[questionId] = answer;
      notifyListeners();

      // Try to sync if online
      if (await AppUtils.isOnline()) {
        _syncResponse(response);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error saving response', e, stackTrace);
      rethrow;
    }
  }

  // Navigate to next question
  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Navigate to previous question
  void previousQuestion() {
    if (!isFirstQuestion) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Sync a single response
  Future<void> _syncResponse(SurveyResponse response) async {
    try {
      final success = await _supabaseService.syncResponse(response);
      if (success) {
        await HiveService.markResponseAsSynced(response.id);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error syncing response', e, stackTrace);
    }
  }

  // Sync all unsynced responses
  Future<bool> syncAllResponses() async {
    if (_isSyncing) return false;

    try {
      _isSyncing = true;
      notifyListeners();

      final unsyncedResponses = await HiveService.getUnsyncedResponses();
      if (unsyncedResponses.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return true;
      }

      final success = await _supabaseService.batchSyncResponses(unsyncedResponses);
      
      if (success) {
        for (var response in unsyncedResponses) {
          await HiveService.markResponseAsSynced(response.id);
        }
      }

      _isSyncing = false;
      notifyListeners();
      return success;
    } catch (e, stackTrace) {
      LoggerService.error('Error syncing all responses', e, stackTrace);
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Reset survey
  void resetSurvey() {
    _currentQuestionIndex = 0;
    _responses.clear();
    notifyListeners();
  }

  // Get sync status
  Future<Map<String, int>> getSyncStatus() async {
    try {
      final responses = await HiveService.getAllResponses();
      final syncedResponses = responses.where((r) => r.synced).length;
      
      return {
        'total': responses.length,
        'synced': syncedResponses,
        'pending': responses.length - syncedResponses,
      };
    } catch (e, stackTrace) {
      LoggerService.error('Error getting sync status', e, stackTrace);
      return {
        'total': 0,
        'synced': 0,
        'pending': 0,
      };
    }
  }
}
