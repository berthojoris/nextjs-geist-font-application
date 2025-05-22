import 'package:hive/hive.dart';

part 'question.g.dart';

enum QuestionType {
  text,
  radio,
  checkbox,
  dropdown,
}

@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final QuestionType type;

  @HiveField(3)
  final List<String>? options;

  @HiveField(4)
  final bool required;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.required = true,
  }) {
    if (type != QuestionType.text && (options == null || options!.isEmpty)) {
      throw ArgumentError('Options are required for non-text questions');
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${json['type']}',
      ),
      options: (json['options'] as List?)?.cast<String>(),
      required: json['required'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options,
      'required': required,
    };
  }
}
