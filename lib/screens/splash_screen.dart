import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/utils/assets.dart';
import 'package:second_xe/utils/routes.dart';
import 'package:second_xe/utils/sizes.dart';
import 'package:second_xe/core/constants/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.logoIC,
              height: 100,
              width: 100,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
            4.h,
            Text(
              APP_NAME,
              style: AppTextStyles.headline2.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
