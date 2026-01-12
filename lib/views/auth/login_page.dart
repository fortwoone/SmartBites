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
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwdCtrl = TextEditingController();

  // Fonction de connexion
  Future<void> _login(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    
    if (_emailCtrl.text.isEmpty || _passwdCtrl.text.isEmpty) {
      _showSnack(context, loc.fill_fields, AppColors.warning);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailCtrl.text.trim())) {
      _showSnack(context, loc.error_invalid_email, AppColors.error);
      return;
    }

    try {
      await ref.read(authViewModelProvider.notifier).signIn(
        _emailCtrl.text.trim(),
        _passwdCtrl.text.trim(),
      );
    } catch (e) {
      if (context.mounted) {
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
                    const SizedBox(height: 40),
                    const LoginHeader(),
                    const SizedBox(height: 48),
                    _buildForm(loc),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      onPressed: () => _login(context),
                      label: loc.perform_login,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 24),
                    _buildRegisterLink(context, loc),
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

  // Formulaire de connexion
  Widget _buildForm(AppLocalizations loc) {
    return Container(
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
            controller: _emailCtrl,
            hint: loc.email_hint,
            icon: Icons.email_outlined,
            label: loc.email,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _passwdCtrl,
            hint: loc.hint_passwd,
            icon: Icons.lock_outline,
            label: loc.password,
            isPassword: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Lien vers la page d'inscription
  Widget _buildRegisterLink(BuildContext context, AppLocalizations loc) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(loc.login_register, style: GoogleFonts.recursive(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            SlideAndFadePageRoute(page: const RegisterPage(), direction: AxisDirection.right),
          ),
          child: Text(
            loc.login_register_action,
            style: GoogleFonts.recursive(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
