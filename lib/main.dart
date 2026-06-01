import 'package:fit_app/providers/subscription_provider.dart';
import 'package:fit_app/screens/splash_screen.dart';
import 'package:fit_app/screens/BuildYourProfileScreen.dart';
import 'package:fit_app/screens/ForgotPasswordScreen.dart'
    show ForgotPasswordScreen;
import 'package:fit_app/screens/OTPVerificationScreen.dart';
import 'package:fit_app/screens/CreateNewPasswordScreen.dart';
import 'package:fit_app/screens/RoleScreen.dart';
import 'package:fit_app/screens/SignUpScreen.dart';
import 'package:fit_app/screens/home_screen.dart';
import 'package:fit_app/screens/login_screen.dart';
import 'package:fit_app/screens/CoachHomeScreen.dart';
import 'package:fit_app/screens/CoachInfoScreen.dart';
import 'package:fit_app/screens/coach/CoachNotificationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_app/services/chat_service.dart';
import 'package:fit_app/logic/cubits/chat/conversations_cubit.dart';
import 'package:fit_app/logic/cubits/chat/start_conversation_cubit.dart';
import 'package:fit_app/logic/cubits/chat/unread_count_cubit.dart';
import 'package:fit_app/logic/cubits/chat/ai_chat_cubit.dart';
import 'package:fit_app/logic/cubits/workout/workouts_cubit.dart';
import 'package:fit_app/logic/cubits/nutrition/nutrition_cubit.dart';
import 'package:fit_app/logic/cubits/store/store_cubit.dart';
import 'package:fit_app/logic/cubits/store/cart_cubit.dart';
import 'package:fit_app/logic/cubits/store/orders_cubit.dart';
import 'package:fit_app/services/workout_service.dart';
import 'package:fit_app/services/nutrition_service.dart';
import 'package:fit_app/services/store_service.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ConversationsCubit(ChatService())),
          BlocProvider(create: (context) => StartConversationCubit(ChatService())),
          BlocProvider(create: (context) => UnreadCountCubit(ChatService())..fetchUnreadCount()),
          BlocProvider(create: (context) => AIChatCubit(ChatService())..loadHistory()),
          BlocProvider(create: (context) => WorkoutsCubit(WorkoutService())),
          BlocProvider(create: (context) => NutritionCubit(NutritionService())),
          BlocProvider(create: (context) => StoreCubit(StoreService())),
          BlocProvider(create: (context) => CartCubit(StoreService())),
          BlocProvider(create: (context) => OrdersCubit(StoreService())),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Fitness Onboarding',
          debugShowCheckedModeBanner: false,
        builder: (context, child) => GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child!,
        ),
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Poppins',
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/otp-verification': (context) => const OTPVerificationScreen(),
          '/create-new-password': (context) => const CreateNewPasswordScreen(),
          '/role': (context) => const RoleScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/build-your-profile': (context) => const BuildYourProfileScreen(),
          '/coach-home': (context) => const CoachHomeScreen(),
          '/coach-info': (context) => const CoachInfoScreen(),
          '/coach-notifications': (context) => const CoachNotificationScreen(),
        },
      ),
    ),
  );
}
}
