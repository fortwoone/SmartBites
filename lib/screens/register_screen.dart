import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:SmartBites/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
    const RegisterScreen({super.key});

    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final supabase = Supabase.instance.client;
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passwdCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    bool isLoading = false;

    Future<void> _performRegister(BuildContext context) async {
        final loc = AppLocalizations.of(context)!;

        if (emailCtrl.text.isEmpty || passwdCtrl.text.isEmpty || nameCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.fill_fields)),
            );
            return;
        }

        setState(() => isLoading = true);

        try {
            final AuthResponse response = await supabase.auth.signUp(
                email: emailCtrl.text.trim(),
                password: passwdCtrl.text.trim(),
                data: {
                    'display_name': nameCtrl.text.trim(),
                },
            );

            if (response.user != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.register_success)),
                );
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                );
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.register_failed)),
                );
            }
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${loc.register_failed}: $e')),
            );
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
                            Color(0xFFF6B092),
                            Color(0xFFF6CF92),
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
                                    loc.register,
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        'Nom',
                                        style: const TextStyle(fontSize: 18),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: nameCtrl,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.person),
                                        filled: true,
                                        fillColor: Colors.white.withAlpha(204),
                                        hintText: 'Entrez votre nom',
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
                                        fillColor: Colors.white.withAlpha(204),
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
                                        fillColor: Colors.white.withAlpha(204),
                                        hintText: loc.hint_passwd,
                                    ),
                                ),
                                const SizedBox(height: 30),
                                isLoading ? const CircularProgressIndicator()
                                : FilledButton(
                                    onPressed: () => _performRegister(context),
                                    child: Text(loc.validate),
                                ),
                                const SizedBox(height: 30),
                                FilledButton(
                                    onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => LoginScreen()),
                                        );
                                    },
                                    child: Text(loc.cancel),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
