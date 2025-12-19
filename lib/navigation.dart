import 'package:get/get.dart';
import 'package:code_initial/presentation/pages/home/home_page.dart';
import 'package:code_initial/presentation/pages/checkout/checkout_page.dart';
import 'package:code_initial/presentation/pages/profile/profile_page.dart';

class Nav {
  static List<GetPage> routes = [
    GetPage(name: Routes.HOME, page: () => const HomePage()),
    GetPage(name: Routes.CHECKOUT, page: () => const CheckoutPage()),
    GetPage(name: Routes.PROFILE, page: () => const ProfilePage()),
  ];
}

class Routes {
  static Future<String> get initialRoute async {
    return HOME;
  }

  static const String MAIN = "/";
  static const HOME = '/home';
  static const CHECKOUT = '/checkout';
  static const PROFILE = '/profile';
}
