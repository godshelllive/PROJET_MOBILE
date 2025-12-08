import 'package:code_initial/presentation/pages/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends GetView<RegisterController> {
  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bienvenue',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Connectez-vous ou créez votre compte pour découvrir nos collections.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => Row(
                    children: [
                      _Segment(
                        label: 'Se connecter',
                        selected: controller.isLogin.value,
                        onTap: () => controller.isLogin.value = true,
                      ),
                      const SizedBox(width: 8),
                      _Segment(
                        label: "S'inscrire",
                        selected: !controller.isLogin.value,
                        onTap: () => controller.isLogin.value = false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        validator: controller.validatePassword,
                      ),
                      Obx(
                        () => controller.isLogin.value
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller:
                                        controller.confirmPasswordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirmer le mot de passe',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: controller.validateConfirm,
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => controller.isLogin.value
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Mot de passe oublié ?'),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.loading.value
                                ? null
                                : controller.submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.loading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    controller.isLogin.value
                                        ? 'Se connecter'
                                        : "Créer mon compte",
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "En continuant, vous acceptez nos Conditions générales et notre Politique de confidentialité.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
