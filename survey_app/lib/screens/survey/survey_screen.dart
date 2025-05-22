import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/survey_provider.dart';
import '../../services/logger_service.dart';
import '../../utils/app_utils.dart';
import '../admin/admin_screen.dart';
import '../common/loading_screen.dart';
import 'question_widget.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyProvider>(
      builder: (context, surveyProvider, child) {
        if (surveyProvider.isLoading) {
          return const LoadingScreen(message: 'Loading questions...');
        }

        if (surveyProvider.questions.isEmpty) {
          return ErrorScreen(
            message: 'No survey questions found',
            onRetry: () => surveyProvider.initializeSurvey(),
          );
        }

        return WillPopScope(
          onWillPop: () async {
            if (surveyProvider.isFirstQuestion) return true;
            surveyProvider.previousQuestion();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Survey'),
              leading: surveyProvider.isFirstQuestion
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => surveyProvider.previousQuestion(),
                    ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    AppUtils.showSnackBar(
                      context,
                      message: 'Starting new survey...',
                    );
                    surveyProvider.resetSurvey();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: surveyProvider.progress,
                  backgroundColor: ThemeConfig.surfaceColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ThemeConfig.primaryColor,
                  ),
                ),
                
                // Question counter
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Question ${surveyProvider.currentQuestionIndex + 1} of ${surveyProvider.questions.length}',
                    style: ThemeConfig.labelMedium,
                  ),
                ),
                
                // Question content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: QuestionWidget(
                        question: surveyProvider.currentQuestion,
                        value: surveyProvider.responses[
                          surveyProvider.currentQuestion.id
                        ],
                        onAnswered: (answer) {
                          surveyProvider.saveResponse(
                            surveyProvider.currentQuestion.id,
                            answer,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Navigation buttons
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!surveyProvider.isFirstQuestion)
                          ElevatedButton(
                            onPressed: () => surveyProvider.previousQuestion(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: ThemeConfig.textPrimary,
                            ),
                            child: const Text('Previous'),
                          )
                        else
                          const SizedBox(width: 80),
                        
                        ElevatedButton(
                          onPressed: () {
                            if (surveyProvider.isLastQuestion) {
                              _handleSurveyCompletion(context, surveyProvider);
                            } else {
                              surveyProvider.nextQuestion();
                            }
                          },
                          child: Text(
                            surveyProvider.isLastQuestion ? 'Finish' : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminScreen(),
                    ),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer),
                  label: 'Survey',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings),
                  label: 'Admin',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSurveyCompletion(
    BuildContext context,
    SurveyProvider surveyProvider,
  ) async {
    try {
      // Check if all required questions are answered
      final unansweredQuestions = surveyProvider.questions.where((q) {
        return q.required &&
            !surveyProvider.responses.containsKey(q.id);
      }).toList();

      if (unansweredQuestions.isNotEmpty) {
        AppUtils.showSnackBar(
          context,
          message: 'Please answer all required questions',
          isError: true,
        );
        return;
      }

      // Try to sync responses if online
      if (await AppUtils.isOnline()) {
        final success = await surveyProvider.syncAllResponses();
        if (success) {
          AppUtils.showSnackBar(
            context,
            message: 'Survey completed and responses synced!',
          );
        } else {
          AppUtils.showSnackBar(
            context,
            message: 'Survey completed but sync failed. Responses saved locally.',
            isError: true,
          );
        }
      } else {
        AppUtils.showSnackBar(
          context,
          message: 'Survey completed! Responses will sync when online.',
        );
      }

      // Reset survey for next user
      surveyProvider.resetSurvey();
    } catch (e, stackTrace) {
      LoggerService.error('Error completing survey', e, stackTrace);
      AppUtils.showSnackBar(
        context,
        message: 'Error completing survey: ${e.toString()}',
        isError: true,
      );
    }
  }
}
