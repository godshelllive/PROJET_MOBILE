import 'package:code_initial/presentation/pages/register/register_page.dart';
import 'package:code_initial/presentation/pages/register/register_controller.dart';
import 'package:get/get.dart';
import 'package:code_initial/presentation/pages/onboarding/onboarding_page.dart';
import 'package:code_initial/presentation/pages/onboarding/onboarding_controller.dart';
import 'package:code_initial/presentation/pages/auth/login_page.dart';
import 'package:code_initial/presentation/pages/auth/signup_page.dart';
import 'package:code_initial/presentation/pages/splashscreen/splash_screen_page.dart';
import 'package:code_initial/presentation/pages/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nav {
  static List<GetPage> routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen2Page()),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(name: Routes.HOME, page: () => const HomePage()),
  ];
}

class Routes {
  static Future<String> get initialRoute async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    return loggedIn ? HOME : SPLASH;
  }

  static const String MAIN = "/";

  static const REGISTER = '/register';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const ONBOARDING = '/onboarding';
  static const SPLASH = '/splash';
  static const HOME = '/home';
}
