import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/db/database.dart';
import 'package:food/db/tables.dart';
import 'package:food/l10n/app_localizations.dart';
import "package:openfoodfacts/openfoodfacts.dart";

void main() {
    runApp(const MyApp());
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
    int _counter = 0;

    final edit_controller = TextEditingController();

    void _incrementCounter() {
        setState(() {
            _counter++;
        });
    }

    Future<String?> askListName(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return showDialog(
            context: context,
            builder: (context){
                return AlertDialog(
                    title: Text(loc.name_shop_list),
                    content: TextField(
                        controller: edit_controller,
                    ),
                    actions: [
                        ElevatedButton(
                            child: Text(loc.cancel),
                            onPressed: () => Navigator.pop(context)
                        ),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context, edit_controller.text),
                            child: Text(loc.ok)
                        )
                    ]
                );
            }
        );
    }

    @override
    Widget build(BuildContext context) {
        final t = AppLocalizations.of(context)!;

        // On rendra ça variable en fonction de la langue après s'être assurés du bon accès à l'API.
        OpenFoodAPIConfiguration.userAgent = UserAgent(name: "SmartBites");
        OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.FRANCE;
        OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.FRENCH];

        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(t.homePageTitle),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(t.pushButtonMessage),
                        Text(
                            '$_counter',
                            style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                            onPressed: onPressed, icon: Icon(Icons.add)
                        )
                    ],
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async{
                    String? result = await askListName(context);
                    print(result);
                    if (result != null && result.isNotEmpty){
                        DBAccess.inst.upsertList(
                            DBShoppingList(name: result)
                        );
                    }
                },
                tooltip: t.increment,
                child: const Icon(Icons.add),
            ),
        );
    }
}
