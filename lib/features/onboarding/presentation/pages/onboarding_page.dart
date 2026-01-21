import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      image: 'assets/images/onboarding_3d_1.png',
      title: 'Master Your\nSchedule',
      description:
          'Take control of your studies with a dynamic 3D planner designed for ultimate focus.',
      themeColor: const Color(0xFFFFF4E1),
      accentColor: const Color(0xFFF57C00),
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_3d_2.png',
      title: 'Study Smarter,\nNot Harder',
      description:
          'All your resources, tasks, and notes in one ultra-modern, integrated dashboard.',
      themeColor: const Color(0xFFFFF8E1),
      accentColor: const Color(0xFFFF8F00),
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_3d_3.png',
      title: 'Reach Your\nPeak Goals',
      description:
          'Track every milestone and achieve your potential with premium study analytics.',
      themeColor: const Color(0xFFFFF3E0),
      accentColor: const Color(0xFFE65100),
    ),
  ];

  void _finishOnboarding() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());

    final userState = context.read<UserBloc>().state;
    if (userState.status == UserStatus.authenticated &&
        userState.user != null) {
      context.goNamed(AppRouteNames.home);
    } else {
      context.goNamed(AppRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: 500.ms,
        color: _items[_currentPage].themeColor,
        child: Stack(
          children: [
            // Side-Swippable Content
            PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Column(
                  children: [
                    // Section 1: Illustration (55% height)
                    Container(
                      height: 0.55.sh,
                      padding: EdgeInsets.only(
                        top: 80.h,
                        left: 32.w,
                        right: 32.w,
                      ),
                      child: Center(
                        child: Image.asset(item.image, fit: BoxFit.contain)
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 800.ms,
                              curve: Curves.easeOutBack,
                            )
                            .moveY(
                              begin: 12,
                              end: -12,
                              duration: 2500.ms,
                              curve: Curves.easeInOut,
                            ),
                      ),
                    ),

                    // Section 2: Title (20% height)
                    Container(
                      height: 0.20.sh,
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      alignment: Alignment.center,
                      child:
                          Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 38.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                  color: const Color(
                                    0xFF2D1B29,
                                  ), // High contrast dark
                                  letterSpacing: -1,
                                ),
                              )
                              .animate(key: ValueKey('title_$index'))
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                    ),

                    // Section 3: Description (20% height)
                    Container(
                      height: 0.20.sh,
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      alignment: Alignment.topCenter,
                      child:
                          Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              )
                              .animate(key: ValueKey('desc_$index'))
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                    ),

                    // Spacer for bottom padding (5% height)
                    SizedBox(height: 0.05.sh),
                  ],
                );
              },
            ),

            // Navigation Layer (Persistent Elements)
            Positioned(
              left: 40.w,
              right: 40.w,
              bottom: 40.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: 350.ms,
                        margin: EdgeInsets.only(right: 8.w),
                        height: 6.h,
                        width: _currentPage == index ? 24.w : 6.w,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _items[_currentPage].accentColor
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _items.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: 600.ms,
                          curve: Curves.easeInOutQuart,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: 400.ms,
                      height: 64.h,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: _items[_currentPage].accentColor,
                        borderRadius: BorderRadius.circular(32.r),
                        boxShadow: [
                          BoxShadow(
                            color: _items[_currentPage].accentColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: 300.ms,
                          child: _currentPage == _items.length - 1
                              ? Text(
                                  'Get Started',
                                  key: const ValueKey('btn_text'),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward_rounded,
                                  key: const ValueKey('btn_icon'),
                                  color: Colors.white,
                                  size: 28.r,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top-right Skip Button
            Positioned(
              top: 50.h,
              right: 24.w,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Skip',
                  style: GoogleFonts.outfit(
                    color: Colors.black38,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingItem {
  final String image;
  final String title;
  final String description;
  final Color themeColor;
  final Color accentColor;

  _OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    required this.themeColor,
    required this.accentColor,
  });
}
