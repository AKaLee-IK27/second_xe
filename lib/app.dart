import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:second_xe/screens/create_post_screen.dart';
import 'package:second_xe/screens/edit_profile_screen.dart';
import 'package:second_xe/screens/forgot_password_screen.dart';
import 'package:second_xe/screens/home_screen.dart';
import 'package:second_xe/screens/login_screen.dart';
import 'package:second_xe/screens/sign_up_screen.dart';
import 'package:second_xe/screens/splash_screen.dart';
import 'package:second_xe/utils/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.signUp: (context) => const SignUpScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.createPost: (context) => const CreatePostScreen(),
            AppRoutes.editProfile: (context) => const EditProfileScreen(),
          },
        );
      },
    );
  }
}
