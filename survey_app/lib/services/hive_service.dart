import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/survey_response.dart';

class HiveService {
  static const String questionsBox = 'questions';
  static const String responsesBox = 'responses';
  static const uuid = Uuid();

  // Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(QuestionAdapter());
    Hive.registerAdapter(QuestionTypeAdapter());
    Hive.registerAdapter(SurveyResponseAdapter());
    
    // Open boxes
    await Hive.openBox<Question>(questionsBox);
    await Hive.openBox<SurveyResponse>(responsesBox);

    // Initialize sample questions if none exist
    final questionBox = Hive.box<Question>(questionsBox);
    if (questionBox.isEmpty) {
      await _initializeSampleQuestions();
    }
  }

  // Sample questions initialization
  static Future<void> _initializeSampleQuestions() async {
    final questions = [
      Question(
        id: uuid.v4(),
        text: 'How satisfied are you with the event organization?',
        type: QuestionType.radio,
        options: ['Very Satisfied', 'Satisfied', 'Neutral', 'Dissatisfied', 'Very Dissatisfied'],
      ),
      Question(
        id: uuid.v4(),
        text: 'What aspects of the event did you enjoy the most?',
        type: QuestionType.checkbox,
        options: ['Content', 'Networking', 'Venue', 'Food & Beverages', 'Organization'],
      ),
      Question(
        id: uuid.v4(),
        text: 'Please provide any additional feedback about the event.',
        type: QuestionType.text,
      ),
      Question(
        id: uuid.v4(),
        text: 'How likely are you to recommend this event to others?',
        type: QuestionType.radio,
        options: ['Highly Likely', 'Likely', 'Neutral', 'Unlikely', 'Highly Unlikely'],
      ),
      Question(
        id: uuid.v4(),
        text: 'Which session format do you prefer?',
        type: QuestionType.dropdown,
        options: ['Workshops', 'Presentations', 'Panel Discussions', 'Interactive Sessions', 'Networking Events'],
      ),
      Question(
        id: uuid.v4(),
        text: 'What topics would you like to see in future events?',
        type: QuestionType.checkbox,
        options: ['Technology', 'Business', 'Leadership', 'Innovation', 'Industry Trends'],
      ),
      Question(
        id: uuid.v4(),
        text: 'Rate the quality of presentations',
        type: QuestionType.radio,
        options: ['Excellent', 'Good', 'Average', 'Fair', 'Poor'],
      ),
      Question(
        id: uuid.v4(),
        text: 'How was the event venue?',
        type: QuestionType.radio,
        options: ['Excellent', 'Good', 'Average', 'Fair', 'Poor'],
      ),
      Question(
        id: uuid.v4(),
        text: 'What improvements would you suggest for future events?',
        type: QuestionType.text,
      ),
      Question(
        id: uuid.v4(),
        text: 'Select your preferred time for future events',
        type: QuestionType.dropdown,
        options: ['Morning', 'Afternoon', 'Evening', 'Weekend Morning', 'Weekend Afternoon'],
      ),
    ];

    final box = Hive.box<Question>(questionsBox);
    for (var question in questions) {
      await box.put(question.id, question);
    }
  }

  // CRUD operations for questions
  static Future<List<Question>> getAllQuestions() async {
    final box = Hive.box<Question>(questionsBox);
    return box.values.toList();
  }

  static Future<void> saveQuestion(Question question) async {
    final box = Hive.box<Question>(questionsBox);
    await box.put(question.id, question);
  }

  // CRUD operations for responses
  static Future<void> saveResponse(SurveyResponse response) async {
    final box = Hive.box<SurveyResponse>(responsesBox);
    await box.put(response.id, response);
  }

  static Future<List<SurveyResponse>> getAllResponses() async {
    final box = Hive.box<SurveyResponse>(responsesBox);
    return box.values.toList();
  }

  static Future<List<SurveyResponse>> getUnsyncedResponses() async {
    final box = Hive.box<SurveyResponse>(responsesBox);
    return box.values.where((response) => !response.synced).toList();
  }

  static Future<void> markResponseAsSynced(String responseId) async {
    final box = Hive.box<SurveyResponse>(responsesBox);
    final response = box.get(responseId);
    if (response != null) {
      response.synced = true;
      await response.save();
    }
  }
}
