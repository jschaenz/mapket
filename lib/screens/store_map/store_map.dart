import 'package:flutter/material.dart';
import 'package:mapket/screens/store_map/grid.dart';
import 'package:mapket/screens/store_map/maps.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreMap extends StatelessWidget {
  const StoreMap({Key? key}) : super(key: key);

  /// scaffold to navigate to the available maps or to the map builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.map),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const Grid()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.map_builder, textScaleFactor: 2),
                        Icon(Icons.build)
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
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const Maps()));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.maps, textScaleFactor: 2),
                        Icon(Icons.map)
                      ],
                    ),
                  ),
                ),
              ),

            ]),
      ),
    );
  }
}
