import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../../utils/error_handler.dart';
import '../../utils/page_transitions.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/login_header.dart';
import '../../widgets/primary_button.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Fonction d'inscription
  Future<void> _register(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    if (_emailCtrl.text.isEmpty || _passwdCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      _showSnack(context, loc.fill_fields, AppColors.warning);
      return;
    }
    if (_passwdCtrl.text.length < 6) {
      _showSnack(context, loc.password_too_short, AppColors.error);
      return;
    }
    if (_passwdCtrl.text != _confirmCtrl.text) {
      _showSnack(context, loc.passwords_not_match, AppColors.error);
      return;
    }

    try {
      await ref.read(authViewModelProvider.notifier).signUp(
        _emailCtrl.text.trim(),
        _passwdCtrl.text.trim(),
      );
      if (mounted) {
         _showSnack(context, loc.register_success, AppColors.success);
         Navigator.of(context).pushReplacement(
            SlideAndFadePageRoute(page: const LoginPage(), direction: AxisDirection.left),
          );
      }
    } catch (e) {
      if (mounted) {
         _showSnack(context, getReadableErrorMessage(e, context), AppColors.error);
      }
    }
  }

  // Afficher un SnackBar
  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isLoading = ref.watch(authViewModelProvider).isLoading;
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    LoginHeader(title: loc.register_title, subtitle: loc.subtitle_register),
                    const SizedBox(height: 24),
                    _buildForm(loc),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      onPressed: () => _register(context),
                      label: loc.validate,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildLoginLink(context, loc),
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

  // Formulaire d'inscription
  Widget _buildForm(AppLocalizations loc) {
    return Container(
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
          AuthTextField(controller: _emailCtrl, hint: loc.email_hint, icon: Icons.email_outlined, label: loc.email),
          const SizedBox(height: 14),
          AuthTextField(controller: _passwdCtrl, hint: loc.hint_passwd, icon: Icons.lock_outline, label: loc.password, isPassword: true),
          const SizedBox(height: 14),
          AuthTextField(controller: _confirmCtrl, hint: loc.hint_conf_passwd, icon: Icons.lock_outline, label: loc.conf_passwd, isPassword: true),
        ],
      ),
    );
  }

  // Lien vers la page de connexion
  Widget _buildLoginLink(BuildContext context, AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(loc.register_login, style: GoogleFonts.recursive(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            SlideAndFadePageRoute(page: const LoginPage(), direction: AxisDirection.left),
          ),
          child: Text(
            loc.register_login_action,
            style: GoogleFonts.recursive(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
