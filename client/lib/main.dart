import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/localizations/app_localization_delegate.dart';
import 'package:binary_success/helpers/logger/logger.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import 'package:binary_success/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helpers/localizations/language.dart';
import 'helpers/services/navigation_service.dart';
import 'helpers/storage/local_storage.dart';
import 'helpers/theme/app_notifier.dart';
import 'helpers/theme/app_style.dart';
import 'helpers/theme/theme_customizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:binary_success/images.dart';

final GoogleSignInPlatform platform = GoogleSignInPlatform.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file from assets
  await dotenv.load(fileName: ".env");

  // Initialize Google SignIn platform with client ID from env
  await platform.init(InitParameters(
    clientId: AppConstant.googleClientIDs,
  ));

  // Configure URL strategy for web
  setPathUrlStrategy();

  // Initialize local storage and themes
  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  // Initialize logger
  initLogger();

  // Initialize API service with URLs from env
  APIService.initializeAPIService(
    devBaseUrl: API.baseURl, // Fixed typo from baseURl
    prodBaseUrl: API.baseURl, // Fixed typo from baseURl
  );

  // Run the app wrapped with ChangeNotifierProvider for theme management
  runApp(
    ChangeNotifierProvider<AppNotifier>(
      create: (context) => AppNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAssetsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    await Future.wait([
      precacheImage(AssetImage(Images.logoCircle), context),
      precacheImage(AssetImage(Images.performance_icon), context),
    ]);
    if (mounted) {
      setState(() {
        _isAssetsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAssetsLoaded) {
      // Show empty container while assets load (usually split second)
      return const SizedBox.shrink();
    }
    
    return Consumer<AppNotifier>(
      builder: (_, notifier, __) {
        return ScreenUtilInit(
          designSize: const Size(1440, 1024),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeCustomizer.instance.theme,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: "/",
            getPages: getPageRoute(),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            localizationsDelegates: [
              AppLocalizationsDelegate(context),
            ],
            supportedLocales: Language.getLocales(),
          ),
        );
      },
    );
  }
}
