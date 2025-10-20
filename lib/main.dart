import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:food/shopping_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url:'https://ftuijeorywnqjgmqbcfk.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0dWlqZW9yeXducWpnbXFiY2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDQ4MDcsImV4cCI6MjA3NjQ4MDgwN30._iADlHpMD_9_5Y_tUnuaayvPwBEW2Dqg4osxUo7ox9U',
    );
    runApp(const MyApp());
}

class LoginScreen extends StatefulWidget{
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    TextEditingController email_ctrl = TextEditingController(),
                          passwd_ctrl = TextEditingController();

    final supabase = Supabase.instance.client;

    @override
    void initState() {
      super.initState();
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                        Text(
                            loc.login,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        Text(
                            loc.email,
                            style: TextStyle(fontSize: 24)
                        ),
                        TextField(
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(border:OutlineInputBorder()),
                            controller: email_ctrl
                        ),
                        Text(
                            loc.password,
                            style: TextStyle(fontSize: 24)
                        ),
                        TextField(
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(border:OutlineInputBorder()),
                            controller: passwd_ctrl
                        ),
                        FilledButton(
                            onPressed: () async {
                                _performLogin(context);
                            },
                            child: Text(loc.perform_login),
                        )
                    ]
                )
            )
        );
    }

    Future<void> _performLogin(BuildContext context) async{
        if (context.mounted){
            final AuthResponse response = await supabase.auth.signInWithPassword(
                email: email_ctrl.text,
                password: passwd_ctrl.text
            );

            Navigator.pop(context, response.session);
        }
    }
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Demo',
            locale: const Locale('fr'), // français par défaut
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const MyHomePage(),
        );
    }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key});

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    Session? session;
    User? user;

    final supabase = Supabase.instance.client;

    Future<void> performLogin(BuildContext context) async{
        final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
        );

        if (!context.mounted){
            return;
        }

        session = result;


        if (session != null){
            await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingListMenu())
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            body: Center(
                child: FilledButton(onPressed: (){
                        performLogin(context);
                    },
                    child: Text(loc.perform_login)
                )
            )
        );
        // return Scaffold(
        //   body: FutureBuilder(
        //     future: _future,
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return const Center(child: CircularProgressIndicator());
        //       }
        //       final instruments = snapshot.data!;
        //       print(instruments);
        //       return ListView.builder(
        //         itemCount: instruments.length,
        //         itemBuilder: ((context, id) {
        //           final instrument = instruments[id];
        //           return ListTile(
        //             title: Text(instrument['name']),
        //           );
        //         }),
        //       );
        //     },
        //   ),
        // );
    }
}
