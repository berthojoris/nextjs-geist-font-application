import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/supabase_service.dart';
import 'services/logger_service.dart';
import 'config/theme_config.dart';
import 'providers/survey_provider.dart';
import 'screens/survey/survey_screen.dart';
import 'screens/common/loading_screen.dart';
import 'utils/app_utils.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize services
    await HiveService.init();
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Initialize device ID
    await AppUtils.getDeviceId();

    LoggerService.info('App initialized successfully');
    
    runApp(const SurveyApp());
  } catch (e, stackTrace) {
    LoggerService.error('Error initializing app', e, stackTrace);
    runApp(MaterialApp(
      home: ErrorScreen(
        message: 'Failed to initialize app: ${e.toString()}',
        onRetry: () {
          // Restart the app
          SystemNavigator.pop();
        },
      ),
    ));
  }
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Survey App',
            theme: ThemeConfig.lightTheme,
            home: const SurveyInitializer(),
            builder: (context, child) {
              // Add error boundary widget
              ErrorWidget.builder = (FlutterErrorDetails details) {
                LoggerService.error('UI Error', details.exception, details.stack);
                return ErrorScreen(
                  message: 'Something went wrong\n${details.exception}',
                  onRetry: () {
                    // Navigate back to survey screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SurveyScreen(),
                      ),
                    );
                  },
                );
              };

              // Add screen util initialization
              if (child == null) return const SizedBox.shrink();
              
              return MediaQuery(
                // Set up text scaling
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

class SurveyInitializer extends StatefulWidget {
  const SurveyInitializer({super.key});

  @override
  State<SurveyInitializer> createState() => _SurveyInitializerState();
}

class _SurveyInitializerState extends State<SurveyInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeSurvey();
  }

  Future<void> _initializeSurvey() async {
    try {
      final surveyProvider = context.read<SurveyProvider>();
      await surveyProvider.initializeSurvey();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SurveyScreen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error initializing survey', e, stackTrace);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              message: 'Failed to load survey: ${e.toString()}',
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyInitializer(),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: 'Initializing survey...',
    );
  }
}
