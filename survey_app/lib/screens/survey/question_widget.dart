import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/question.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final dynamic value;
  final Function(dynamic) onAnswered;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.value,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final TextEditingController _textController = TextEditingController();
  List<String> _selectedCheckboxes = [];

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      if (widget.question.type == QuestionType.text) {
        _textController.text = widget.value as String;
      } else if (widget.question.type == QuestionType.checkbox) {
        _selectedCheckboxes = List<String>.from(widget.value as List);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildQuestionText() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Text(
        widget.question.text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter your answer',
        ),
        maxLines: 3,
        onChanged: widget.onAnswered,
      ),
    );
  }

  Widget _buildRadioButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        children: widget.question.options!.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: widget.value as String?,
            onChanged: (value) {
              widget.onAnswered(value);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        children: widget.question.options!.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: _selectedCheckboxes.contains(option),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedCheckboxes.add(option);
                } else {
                  _selectedCheckboxes.remove(option);
                }
                widget.onAnswered(_selectedCheckboxes);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: DropdownButtonFormField<String>(
        value: widget.value as String?,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        items: widget.question.options!.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          widget.onAnswered(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionText(),
          SizedBox(height: 8.h),
          if (widget.question.type == QuestionType.text) _buildTextInput(),
          if (widget.question.type == QuestionType.radio) _buildRadioButtons(),
          if (widget.question.type == QuestionType.checkbox) _buildCheckboxes(),
          if (widget.question.type == QuestionType.dropdown) _buildDropdown(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
