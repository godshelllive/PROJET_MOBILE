import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/data/repositories/user_repository.dart';

class RegisterController extends GetxController {
  RegisterController();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  final isLogin = true.obs;
  final loading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email requis";
    if (!GetUtils.isEmail(value)) return "Email invalide";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Mot de passe requis";
    if (value.length < 6) return "Au moins 6 caractères";
    return null;
  }

  String? validateConfirm(String? value) {
    if (!isLogin.value) {
      if (value == null || value.isEmpty) return "Confirmer le mot de passe";
      if (value != passwordController.text) {
        return "Les mots de passe diffèrent";
      }
    }
    return null;
  }

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    loading.value = true;
    try {
      if (isLogin.value) {
        final ok = await _login();
        loading.value = false;
        if (ok) {
          Get.snackbar(
            'Connexion',
            'Connecté avec ${emailController.text}',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Erreur',
            'Identifiants incorrects',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        await _signup();
        loading.value = false;
        Get.snackbar(
          'Inscription',
          'Compte créé pour ${emailController.text}',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLogin.value = true;
      }
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _login() async {
    final row = await _repo.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    return row != null;
  }

  Future<void> _signup() async {
    await _repo.signUp(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  late final UserRepository _repo = UserRepository();
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController());
  }
}
