import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mapket/firebase_options.dart';
import 'package:mapket/screens/shopping_list.dart';
import 'package:mapket/screens/store_map/store_map.dart';
import 'package:mapket/screens/store_selection/store_page_overview.dart';
import 'package:mapket/services/database/data_handler_service.dart';
import 'package:mapket/services/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// app entry
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
  DataHandlerService $storageService = getIt<DataHandlerService>();
  await $storageService.loadAllData();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateTitle: (context) {
          return AppLocalizations.of(context)!.title;
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('de', ''),
        ],
        debugShowCheckedModeBanner: false,
        home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShoppingList())),
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(AppLocalizations.of(context)!.shopping_list),
                      const Icon(
                        Icons.format_list_numbered,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const StorePageOverview()))
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.store_finder),
                        const Icon(Icons.location_on_outlined)
                      ],
                    )),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StoreMap()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.store_map),
                        const Icon(Icons.map_outlined)
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
