import 'package:get/get.dart';

class OnboardingController extends GetxController {}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
  }
}
