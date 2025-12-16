import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:SmartBites/screens/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/color_constants.dart';
import '../../utils/page_transitions.dart';
import '../../utils/error_handler.dart';
import '../../widgets/auth/login_header.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwdCtrl = TextEditingController();
  final TextEditingController confirmPasswdCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> _performRegister(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    // Validation des champs vides
    if (emailCtrl.text.trim().isEmpty ||
        passwdCtrl.text.trim().isEmpty ||
        confirmPasswdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.fill_fields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validation du format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailCtrl.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.error_invalid_email),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation de la longueur du mot de passe
    if (passwdCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.password_too_short),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation de la correspondance des mots de passe
    if (passwdCtrl.text != confirmPasswdCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.passwords_not_match),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwdCtrl.text.trim(),
      );

      if (response.user != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.register_success),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Attendre un peu pour que l'utilisateur voie le message de succès
        await Future.delayed(const Duration(milliseconds: 800));

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            SlideAndFadePageRoute(
              page: const LoginScreen(),
              direction: AxisDirection.left,
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.register_failed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        final errorMessage = getReadableErrorMessage(e, context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryPeach.withAlpha(255),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryPeach.withAlpha(13),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    LoginHeader(
                      title: loc.register_title,
                      subtitle: loc.subtitle_register,
                      logoSize: 80,
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: emailCtrl,
                            hint: loc.email_hint,
                            icon: Icons.email_outlined,
                            label: loc.email,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller: passwdCtrl,
                            hint: loc.hint_passwd,
                            icon: Icons.lock_outline,
                            label: loc.password,
                            isPassword: true,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller: confirmPasswdCtrl,
                            hint: loc.hint_conf_passwd,
                            icon: Icons.lock_outline,
                            label: loc.conf_passwd,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            onPressed: () => _performRegister(context),
                            label: loc.validate,
                            isLoading: isLoading,
                          ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.register_login,
                          style: GoogleFonts.recursive(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              SlideAndFadePageRoute(
                                page: const LoginScreen(),
                                direction: AxisDirection.left,
                              ),
                            );
                          },
                          child: Text(
                            loc.register_login_action,
                            style: GoogleFonts.recursive(
                              color: primaryPeach,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
