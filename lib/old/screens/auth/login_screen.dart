import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:SmartBites/old/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import '../../widgets/auth/login_header.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../utils/color_constants.dart';
import '../../utils/page_transitions.dart';
import '../../utils/error_handler.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwdCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> _performLogin(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    if (emailCtrl.text.trim().isEmpty || passwdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.fill_fields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    setState(() => isLoading = true);

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passwdCtrl.text.trim(),
      );

      if (response.session != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.login_failed),
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
            right: -100,
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
            left: -50,
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
                    const SizedBox(height: 40),
                    const LoginHeader(),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
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
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: passwdCtrl,
                            hint: loc.hint_passwd,
                            icon: Icons.lock_outline,
                            label: loc.password,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            onPressed: () => _performLogin(context),
                            label: loc.perform_login,
                            isLoading: isLoading,
                          ),

                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          loc.login_register,
                          style: GoogleFonts.recursive(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              SlideAndFadePageRoute(
                                page: const RegisterScreen(),
                                direction: AxisDirection.right,
                              ),
                            );
                          },
                          child: Text(
                            loc.login_register_action,
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
