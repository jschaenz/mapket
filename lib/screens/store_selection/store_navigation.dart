import 'dart:math';

import 'package:dijkstra/dijkstra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapket/services/database/firestore_map_service.dart';
import 'package:mapket/services/local_storage/shopping_list_entry_service.dart';
import 'package:mapket/services/service_locator.dart';

class StorePageNavigation extends StatefulWidget {
  final String id;

  const StorePageNavigation({Key? key, required this.id}) : super(key: key);

  @override
  StorePageNavigationState createState() => StorePageNavigationState();

  StorePageNavigationState setState() => StorePageNavigationState();
}

class StorePageNavigationState extends State<StorePageNavigation> {
  @override
  void initState() {
    super.initState();
    _mapService
        .getUserInputMapNameDocRef(widget.id)
        .get()
        .then((value) => _data = value)
        .then((value) => setState(() {
              _loading = false;
            }));
  }

  ShoppingListEntryService _shoppingListStorageService =
      getIt<ShoppingListEntryService>();

  FirestoreMapService _mapService = getIt<FirestoreMapService>();

  late var _data;

  bool _loading = true;

  List<String> _colors = [];
  late List<String> _modifiedColors = _colors;
  List<String> _products = [];

  late var _route = List.filled(
      _length,
      Icon(
        Icons.arrow_drop_down,
        size: 0,
      ));

  late int _length;
  late String itemInShelf = "";
  int _index = 0;
  late int _from = _colors.indexWhere((element) {
    return element == Colors.green.value.toString();
  });

  /// scaffold of the map detail view
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold();
    } else
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.map_details),
          ),
          body: Center(
            // ? FIXME: Is container necessary?
            // ignore: avoid_unnecessary_containers
            child: Column(
              children: [
                loadMap(),
                ElevatedButton(
                  onPressed: () {
                    _calculateRoute();
                  },
                  child: Text(AppLocalizations.of(context)!.route),
                )
              ],
            ),
          ));
  }

  /// loads the specific map
  Widget loadMap() {
    // splits the data and saves it as a list to manipulate
    final split = _data["colorValues"].toString().split(";");
    _colors = split;

    final splitProducts = _data["products"].toString().split(";");
    _products = splitProducts;
    return _buildMapBody(split);
  }

  /// returns the map body with the correct data and decoration
  Widget _buildMapBody(List<String> colorValues) {
    _length = int.parse(colorValues.length.toString()) - 1;
    var gridLength = sqrt(_length);
    return Column(children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0,
        child: InteractiveViewer(
          child: Container(
            padding: const EdgeInsets.all(2.0),
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0)),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridLength.floor(),
                ),
                itemCount: gridLength.floor() * gridLength.floor(),
                itemBuilder: (context, index) {
                  return _buildGridItems(context, index);
                }),
          ),
        ),
      ),
    ]);
  }

  /// returns the grid items with the correct color and a checkbox
  Widget _buildGridItems(BuildContext context, int index) {
    // ? FIXME: Is container necessary?
    // ignore: avoid_unnecessary_containers

    return Container(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.2),
          ),
          child: Container(
            decoration:
                BoxDecoration(color: Color(int.parse(_modifiedColors[index]))),
            child: _modifiedColors[index] == Colors.brown.value.toString()
                ? null
                : _route[index],
          ),
        ),
      ),
    );
  }

  /// calculates the route with the Dijkstra algorithm https://pub.dev/packages/dijkstra
  /// list of pairs is generated for the grid which are interconnected, shelfs are excluded
  /// so that is doesnt show a route through shelfs
  Future _calculateRoute() async {
    List<List> pairList = [];
    int i = 0;
    Map<String, dynamic> jsonDecoded =
        await _shoppingListStorageService.loadShoppingList();
    var shoppingList = jsonDecoded.keys.toList();

    _route = List.filled(
        _length,
        Icon(
          Icons.arrow_drop_down,
          size: 0,
        ));

    /// generates the pair list with its neighbors (right, left, under and above)
    _colors.forEach((element) {
      if (i + 1 > _length) {
        return;
      }
      if ((i + 1) % sqrt(_length) != 0 &&
          _colors[i + 1] != Colors.brown.value.toString() &&
          _colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i + 1]); //right
      }
      if ((i - 1) % sqrt(_length) != sqrt(_length) - 1 &&
          _colors[i - 1] != Colors.brown.value.toString() &&
          i - 1 >= 0 &&
          _colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i - 1]); //left
      }
      if ((i + sqrt(_length).toInt()) < _length &&
          _colors[i + sqrt(_length).toInt()] != Colors.brown.value.toString() &&
          _colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i + sqrt(_length).toInt()]); //under
      }
      if ((i - sqrt(_length).toInt()) > _length &&
          _colors[i - sqrt(_length).toInt()] != Colors.brown.value.toString() &&
          _colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i - sqrt(_length).toInt()]); //above
      }
      i++;
    });

    List productsIndex = await _findProductsIndex(shoppingList);

    if (_colors[_from] == Colors.green.value.toString()) {
      _modifiedColors = _colors;
    }
    var output =
        Dijkstra.findPathFromPairsList(pairList, _from, productsIndex[_index]);

    /// searches for the fastest path for the products in the list
    if (output.length == 0 &&
        (productsIndex[_index] + 1) % sqrt(_length) != 0 &&
        _colors[productsIndex[_index] + 1] == Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, _from, productsIndex[_index] + 1);
      _from = productsIndex[_index] + 1;
    } else if (output.length == 0 &&
        (productsIndex[_index] - 1) % sqrt(_length) != sqrt(_length) - 1 &&
        _colors[productsIndex[_index] - 1] == Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, _from, productsIndex[_index] - 1);
      _from = productsIndex[_index] - 1;
    } else if (output.length == 0 &&
        _colors[productsIndex[_index] - sqrt(_length).floor()] ==
            Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, _from, productsIndex[_index] - sqrt(_length).floor());
      _from = productsIndex[_index] - sqrt(_length).floor();
    } else if (output.length == 0) {
      output = Dijkstra.findPathFromPairsList(
          pairList, _from, productsIndex[_index] + sqrt(_length).floor());
      _from = productsIndex[_index] + sqrt(_length).floor();
    }
    // sets the color to light green where the product is
    _modifiedColors[productsIndex[_index]] = Colors.lightGreen.value.toString();

    output.forEach((element) {
      setState(() {
        _markRoute(element);
      });
    });
    _index++;

    /// resets the route
    if (_index == productsIndex.length) {
      _index = 0;
      _from = _colors.indexWhere((element) {
        return element == Colors.green.value.toString();
      });
    }
  }

  /// route is marked with an walking icon
  _markRoute(int index) {
    setState(() {
      _route[index] = Icon(
        Icons.directions_walk,
        size: 10,
      );
    });
  }

  /// finds the index of the products
  _findProductsIndex(List<String> shoppingList) {
    var productListSearch = shoppingList;
    List indexOfProducts = [];
    for (int i = 0; i < productListSearch.length; i++) {
      final first =
          _products.indexWhere((element) => element == productListSearch[i]);
      if (first != -1) {
        indexOfProducts.add(first);
      }
    }
    return indexOfProducts;
  }
}
