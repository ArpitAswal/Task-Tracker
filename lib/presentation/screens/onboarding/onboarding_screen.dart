import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/onboarding_model.dart';
import '../../widgets/common/custom_button.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController(); // A page controller lets you manipulate which page is visible in a PageView
  int _currentPage = 0; // Track the current page index

  // Onboarding data
  List<OnboardingModel> get _onboardingPages => [
    OnboardingModel(
      image: AppConstants.onboardingImage,
      title: AppLocalizations.of(context)!.onboardingTitle,
      description: AppLocalizations.of(context)!.onboardingDescription,
    ),
    OnboardingModel(
      image: "AppConstants.onboardingImage",
      title: AppLocalizations.of(context)!.onboardingTitle,
      description: AppLocalizations.of(context)!.onboardingDescription,
    ),
    OnboardingModel(
      image: AppConstants.onboardingImage,
      title: AppLocalizations.of(context)!.onboardingTitle,
      description: AppLocalizations.of(context)!.onboardingDescription,
    ),
    // Add more onboarding pages here in the future
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    // Save that onboarding is completed
    await StorageService().saveBool(StorageKeys.onboardingCompleted, true);

    if (!mounted) return;

    // Navigate to home screen
    AppRoutes.navigateAndReplace(context, AppRoutes.login);
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        // Animate to the next page
        duration: AppConstants.mediumDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(localization.translate('skip')),
                ),
              ),
              const SizedBox(height: 16.0),

              // PageView with onboarding content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _onboardingPages[index]);
                  },
                ),
              ),

              const SizedBox(height: 16.0),
              // Page indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _onboardingPages.length,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.onPrimary,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: AppConstants.mediumDuration,
                    curve: Curves.easeInOut,
                  );
                },
              ),

              // Continue/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: CustomButton(
                  text: isLastPage
                      ? localization.letsStart
                      : localization.translate('continue'),
                  onPressed: _nextPage,
                  icon: const Icon(Icons.arrow_forward),
                  width: size.width * 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
