import 'package:flutter/material.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:food/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';


// Palette pêche (définie localement dans ce fichier)
const Color primaryPeach = Color(0xFFF6B092);
const Color accentPeach = Color(0xFFF6CF92);

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
        if (emailCtrl.text.isEmpty || passwdCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.fill_fields)),
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
                if (!context.mounted){
                    return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.login_failed)),
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
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                            primaryPeach,
                            accentPeach,
                         ],
                     ),
                 ),
                child: Center(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: Image.asset(
                                      'lib/ressources/logo_App.png',
                                      fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Text(
                                    loc.login,
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        loc.email,
                                        style: const TextStyle(fontSize: 18),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: emailCtrl,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.email),
                                        filled: true,
                                        fillColor: Colors.white.withAlpha(204), // ~0.8 * 255 = 204
                                        hintText: loc.email_hint,
                                    ),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        loc.password,
                                        style: const TextStyle(fontSize: 18),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: passwdCtrl,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.lock),
                                        filled: true,
                                        fillColor: Colors.white.withAlpha(204), // ~0.8 * 255 = 204
                                        hintText: loc.hint_passwd,
                                    ),
                                ),
                                const SizedBox(height: 30),
                                isLoading ? const CircularProgressIndicator()
                                : FilledButton(
                                  onPressed: () => _performLogin(context),
                                  child: Text(loc.perform_login),
                                ),
                                const SizedBox(height: 30),
                                FilledButton(
                                    onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                                        );
                                    },
                                    child: Text(loc.register),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
