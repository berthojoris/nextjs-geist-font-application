import 'package:hive/hive.dart';

part 'survey_response.g.dart';

@HiveType(typeId: 1)
class SurveyResponse extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String questionId;

  @HiveField(2)
  final dynamic answer;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  bool synced;

  SurveyResponse({
    required this.id,
    required this.questionId,
    required this.answer,
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      answer: json['answer'],
      timestamp: DateTime.parse(json['timestamp'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced,
    };
  }
}
