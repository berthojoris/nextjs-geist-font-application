import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/survey_provider.dart';
import '../../services/logger_service.dart';
import '../../utils/app_utils.dart';
import '../common/loading_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyProvider>(
      builder: (context, surveyProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Panel'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : () => _refreshData(surveyProvider),
              ),
            ],
          ),
          body: _isLoading
              ? const LoadingScreen(message: 'Loading responses...')
              : Column(
                  children: [
                    // Sync status card
                    _buildSyncStatusCard(surveyProvider),
                    
                    // Responses list
                    Expanded(
                      child: _buildResponsesList(surveyProvider),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSyncStatusCard(SurveyProvider surveyProvider) {
    return Card(
      margin: EdgeInsets.all(16.sp),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Status',
              style: ThemeConfig.titleLarge,
            ),
            SizedBox(height: 16.h),
            FutureBuilder<Map<String, int>>(
              future: surveyProvider.getSyncStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error loading sync status',
                    style: ThemeConfig.bodyMedium.copyWith(
                      color: ThemeConfig.error,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final status = snapshot.data!;
                return Column(
                  children: [
                    _buildStatusRow(
                      'Total Responses',
                      status['total']!,
                      ThemeConfig.primaryColor,
                    ),
                    SizedBox(height: 8.h),
                    _buildStatusRow(
                      'Synced',
                      status['synced']!,
                      ThemeConfig.success,
                    ),
                    SizedBox(height: 8.h),
                    _buildStatusRow(
                      'Pending Sync',
                      status['pending']!,
                      ThemeConfig.warning,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: surveyProvider.isSyncing
                          ? null
                          : () => _syncResponses(surveyProvider),
                      icon: surveyProvider.isSyncing
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(
                        surveyProvider.isSyncing ? 'Syncing...' : 'Sync Now',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ThemeConfig.bodyMedium,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            value.toString(),
            style: ThemeConfig.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsesList(SurveyProvider surveyProvider) {
    return FutureBuilder(
      future: surveyProvider.getSyncStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading responses',
              style: ThemeConfig.bodyMedium.copyWith(
                color: ThemeConfig.error,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final responses = surveyProvider.responses;
        if (responses.isEmpty) {
          return Center(
            child: Text(
              'No responses yet',
              style: ThemeConfig.bodyMedium.copyWith(
                color: ThemeConfig.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: surveyProvider.questions.length,
          itemBuilder: (context, index) {
            final question = surveyProvider.questions[index];
            final response = responses[question.id];
            
            return Card(
              margin: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              child: ListTile(
                title: Text(
                  question.text,
                  style: ThemeConfig.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      'Type: ${question.type.toString().split('.').last}',
                      style: ThemeConfig.labelMedium,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Answer: ${response?.toString() ?? 'Not answered'}',
                      style: ThemeConfig.bodyMedium,
                    ),
                  ],
                ),
                trailing: Icon(
                  response != null
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: response != null
                      ? ThemeConfig.success
                      : ThemeConfig.textSecondary,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refreshData(SurveyProvider surveyProvider) async {
    setState(() => _isLoading = true);
    try {
      await surveyProvider.initializeSurvey();
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          message: 'Data refreshed successfully',
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error refreshing data', e, stackTrace);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          message: 'Error refreshing data: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncResponses(SurveyProvider surveyProvider) async {
    if (!await AppUtils.isOnline()) {
      AppUtils.showSnackBar(
        context,
        message: 'No internet connection',
        isError: true,
      );
      return;
    }

    try {
      final success = await surveyProvider.syncAllResponses();
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          message: success
              ? 'Responses synced successfully'
              : 'Failed to sync some responses',
          isError: !success,
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error syncing responses', e, stackTrace);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          message: 'Error syncing responses: ${e.toString()}',
          isError: true,
        );
      }
    }
  }
}
