import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _loadingOpacityAnimation;

  bool _isInitializing = true;
  String _loadingText = 'กำลังเริ่มต้น...';
  bool _showRetryOption = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Loading opacity animation
    _loadingOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));

    // Start logo animation
    _logoAnimationController.forward();

    // Start loading animation after logo animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _loadingAnimationController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style for dark theme
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Simulate initialization tasks
      await _performInitializationTasks();

      // Navigate based on authentication status
      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    final List<Future<void>> initTasks = [];

    // Task 1: Check authentication status
    initTasks.add(_checkAuthenticationStatus());

    // Task 2: Load user preferences
    initTasks.add(_loadUserPreferences());

    // Task 3: Fetch Ayrshare API configuration
    initTasks.add(_fetchAPIConfiguration());

    // Task 4: Prepare cached social media data
    initTasks.add(_prepareCachedData());

    // Execute all tasks with timeout
    await Future.wait(initTasks).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Initialization timeout');
      },
    );
  }

  Future<void> _checkAuthenticationStatus() async {
    setState(() {
      _loadingText = 'ตรวจสอบสถานะการเข้าสู่ระบบ...';
    });
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _loadingText = 'โหลดการตั้งค่าผู้ใช้...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _fetchAPIConfiguration() async {
    setState(() {
      _loadingText = 'เชื่อมต่อกับเซิร์ฟเวอร์...';
    });
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<void> _prepareCachedData() async {
    setState(() {
      _loadingText = 'เตรียมข้อมูลโซเชียลมีเดีย...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _navigateToNextScreen() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Simulate authentication check
    final bool isAuthenticated = await _checkUserAuthentication();
    final bool isFirstTime = await _checkFirstTimeUser();

    // Fade out animation
    await _logoAnimationController.reverse();

    if (!mounted) return;

    // Navigate based on user status
    if (isAuthenticated) {
      // Authenticated user - go to dashboard
      Navigator.pushReplacementNamed(context, '/content-calendar');
    } else if (isFirstTime) {
      // First time user - show onboarding (fallback to login)
      Navigator.pushReplacementNamed(context, '/login-screen');
    } else {
      // Returning non-authenticated user - go to login
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  Future<bool> _checkUserAuthentication() async {
    // Simulate authentication check
    // In real implementation, check stored tokens/credentials
    return false; // Default to non-authenticated for demo
  }

  Future<bool> _checkFirstTimeUser() async {
    // Simulate first time user check
    // In real implementation, check shared preferences
    return false; // Default to returning user for demo
  }

  void _handleInitializationError() {
    setState(() {
      _isInitializing = false;
      _showRetryOption = true;
      _loadingText = 'เกิดข้อผิดพลาดในการเริ่มต้น';
    });

    // Show retry option after 5 seconds if still on screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_showRetryOption) {
        setState(() {
          _showRetryOption = true;
        });
      }
    });
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _showRetryOption = false;
      _loadingText = 'กำลังเริ่มต้นใหม่...';
    });

    // Reset animations
    _logoAnimationController.reset();
    _loadingAnimationController.reset();

    // Restart initialization
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // App Logo Section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: _buildAppLogo(),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // Loading Section
              AnimatedBuilder(
                animation: _loadingAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacityAnimation.value,
                    child: _buildLoadingSection(),
                  );
                },
              ),

              // Spacer to balance layout
              const Spacer(flex: 3),

              // Retry Section (if needed)
              if (_showRetryOption) _buildRetrySection(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.onPrimary,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              'CF',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 6.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Loading Indicator
        if (_isInitializing)
          SizedBox(
            width: 8.w,
            height: 8.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              backgroundColor: AppTheme.border,
            ),
          ),

        SizedBox(height: 3.h),

        // Loading Text
        Container(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Text(
            _loadingText,
            textAlign: TextAlign.center,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App Name
        Text(
          'Contentflow Pro',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),

        SizedBox(height: 1.h),

        // App Tagline
        Container(
          constraints: BoxConstraints(maxWidth: 70.w),
          child: Text(
            'จัดการโซเชียลมีเดียด้วย AI',
            textAlign: TextAlign.center,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetrySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: AppTheme.warning,
            size: 6.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'ไม่สามารถเชื่อมต่อได้',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
            textAlign: TextAlign.center,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ลองใหม่',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
