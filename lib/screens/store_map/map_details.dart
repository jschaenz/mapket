import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:mapket/resources/data_models/product_family.dart';
import 'package:dijkstra/dijkstra.dart';
import 'package:mapket/services/database/firestore_map_service.dart';
import 'package:mapket/services/local_storage/shopping_list_entry_service.dart';
import 'package:mapket/services/service_locator.dart';

class MapDetails extends StatefulWidget {
  final int id;
  final QuerySnapshot data;

  const MapDetails({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<MapDetails> createState() => _MapDetailsState();
}

class _MapDetailsState extends State<MapDetails> {


  FirestoreMapService mapService = getIt<FirestoreMapService>();

  ShoppingListEntryService shoppinglistStorageService =
  getIt<ShoppingListEntryService>();

  List<String> colors = [];
  late List<String> modifiedColors = colors;
  List<String> products = [];
  late var checked = List.filled(
      length,
      Icon(
        Icons.add,
        size: 15,
      ));

  late var productsInShelf = products;

  late var route = List.filled(
      length,
      Icon(
        Icons.arrow_drop_down,
        size: 0,
      ));

  List<String> items =
      EnumToString.toList(ProductFamily.values, camelCase: true);

  late String? selectedItem = items[0];
  late int length;
  late String itemInShelf = "";
  late var productList = products.where((element) {
    return element.length > 1;
  });
  int index = 0;
  late int from = colors.indexWhere((element) {
    return element == Colors.green.value.toString();
  });

  /// scaffold of the map detail view
  @override
  Widget build(BuildContext context) {
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
              DropdownButton(
                value: selectedItem,
                onChanged: (newValue) {
                  setState(() {
                    selectedItem = newValue as String?;
                  });
                },
                items: items.map((location) {
                  return DropdownMenuItem(
                    child: new Text(location),
                    value: location,
                  );
                }).toList(),
              ),
              Text("Currently selected shelf has \n" + itemInShelf,
                  textAlign: TextAlign.center),
              MaterialButton(
                onPressed: () {
                  setState(
                    () {
                      _save(widget.id);
                    },
                  );
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
              MaterialButton(
                onPressed: () {
                  _update();
                },
                child: Text("update"),
              ),
              MaterialButton(
                onPressed: () {
                  _calculateRoute();
                },
                child: Text("Route"),
              )
            ],
          ),
        ));
  }

  /// loads the specific map
  Widget loadMap(){
    final data = widget.data;
    // splits the data and saves it as a list to manipulate
    final split = data.docs[widget.id]["colorValues"]
        .toString()
        .split(";");
    colors = split;

    final splitProducts =
    data.docs[widget.id]["products"].toString().split(";");
    products = splitProducts;
    return _buildMapBody(data, split);
  }

  /// returns the map body with the correct data and decoration
  Widget _buildMapBody(QuerySnapshot data, List<String> colorValues) {
    length = int.parse(colorValues.length.toString()) - 1;
    var gridLength = sqrt(length);
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
            decoration: BoxDecoration(color: Color(int.parse(modifiedColors[index]))),
            child: modifiedColors[index] == Colors.brown.value.toString()
                ? checked[index]
                : route[index],
          ),
        ),
        onTap: () {
          _selectTile(index);
        },
        onLongPress: () {
          _deleteTile(index);
        },
        onDoubleTap: () {
          setState(() {
            itemInShelf = productsInShelf[index];
          });
        },
      ),
    );
  }

  /// selects a tile to put an item in and sets it to checked
  Future _selectTile(int index) async {
    setState(() {
      if (colors[index] == Colors.brown.value.toString()) {
        checked[index] = Icon(
          Icons.check,
          size: 15,
        );
        productsInShelf[index] = selectedItem!;
      }
    });
  }

  /// deletes the item in the tile and sets it back to unchecked
  Future _deleteTile(int index) async {
    setState(() {
      if (colors[index] == Colors.brown.value.toString() &&
          checked[index].toString() ==
              Icon(
                Icons.check,
                size: 15,
              ).toString()) {
        checked[index] = Icon(
          Icons.add,
          size: 15,
        );
        productsInShelf[index] = "";
      }
    });
  }

  /// saves the map with the items in the database
  Future _save(index) async {
    String products = "";
    productsInShelf.forEach((element) {
      products += element;
      products += ";";
    });

    Map<String, String> maps = {
      "products": products,
    };

    mapService.updateMaps("${widget.data.docs[index]["mapTitle"]}", maps);

  }

  //TODO call function last
  /// updates the map to see which shelfs are already checked, needed once at the beginning
  Future _update() async {
    setState(() {
      for (var i = 0; i < products.length; i++) {
        if (products[i].isNotEmpty) {
          checked[i] = Icon(
            Icons.check,
            size: 15,
          );
        }
      }
    });
  }


  /// calculates the route with the Dijkstra algorithm https://pub.dev/packages/dijkstra
  /// list of pairs is generated for the grid which are interconnected, shelfs are excluded
  /// so that is doesnt show a route through shelfs
  Future _calculateRoute() async {
    List<List> pairList = [];
    int i = 0;
    Map<String, dynamic> jsonDecoded = await shoppinglistStorageService.loadShoppingList();
    var shoppingList = jsonDecoded.keys.toList();

    route = List.filled(
        length,
        Icon(
          Icons.arrow_drop_down,
          size: 0,
        ));

    /// generates the pair list with its neighbors (right, left, under and above)
    colors.forEach((element) {
      if (i + 1 > length) {
        return;
      }
      if ((i + 1) % sqrt(length) != 0 &&
          colors[i + 1] != Colors.brown.value.toString() &&
          colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i + 1]); //right
      }
      if ((i - 1) % sqrt(length) != sqrt(length) - 1 &&
          colors[i - 1] != Colors.brown.value.toString() &&
          i - 1 >= 0 &&
          colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i - 1]); //left
      }
      if ((i + sqrt(length).toInt()) < length &&
          colors[i + sqrt(length).toInt()] != Colors.brown.value.toString() &&
          colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i + sqrt(length).toInt()]); //under
      }
      if ((i - sqrt(length).toInt()) > length &&
          colors[i - sqrt(length).toInt()] != Colors.brown.value.toString() &&
          colors[i] != Colors.brown.value.toString()) {
        pairList.add([i, i - sqrt(length).toInt()]); //above
      }
      i++;
    });

    List productsIndex = await _findProductsIndex(shoppingList);

    if(colors[from] == Colors.green.value.toString()){
      modifiedColors = colors;
    }
    var output =
        Dijkstra.findPathFromPairsList(pairList, from, productsIndex[index]);

    /// searches for the fastest path for the products in the list
    if (output.length == 0 &&
        (productsIndex[index] + 1) % sqrt(length) != 0 &&
        colors[productsIndex[index] + 1] == Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, from, productsIndex[index] + 1);
      from = productsIndex[index] + 1;
    } else if (output.length == 0 &&
        (productsIndex[index] - 1) % sqrt(length) != sqrt(length) - 1 &&
        colors[productsIndex[index] - 1] == Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, from, productsIndex[index] - 1);
      from = productsIndex[index] - 1;
    } else if (output.length == 0 &&
        colors[productsIndex[index] - sqrt(length).floor()] ==
            Colors.grey.value.toString()) {
      output = Dijkstra.findPathFromPairsList(
          pairList, from, productsIndex[index] - sqrt(length).floor());
      from = productsIndex[index] - sqrt(length).floor();
    } else if (output.length == 0) {
      output = Dijkstra.findPathFromPairsList(
          pairList, from, productsIndex[index] + sqrt(length).floor());
      from = productsIndex[index] + sqrt(length).floor();
    }
    // sets the color to light green where the product is
    modifiedColors[productsIndex[index]] = Colors.lightGreen.value.toString();


    output.forEach((element) {
      setState(() {
        _markRoute(element);
      });
    });
    index++;

    /// resets the route
    if (index == productsIndex.length) {
      index = 0;
      from = colors.indexWhere((element) {
        return element == Colors.green.value.toString();
      });
    }

  }

  /// route is marked with an walking icon
  _markRoute(int index) {
    setState(() {
      route[index] = Icon(
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
          products.indexWhere((element) => element == productListSearch[i]);
      if (first != -1) {
        indexOfProducts.add(first);
      }
    }
    return indexOfProducts;
  }

}
