import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapket/resources/data_models/product_data.dart';
import 'package:mapket/resources/data_models/store_list_data.dart';
import 'package:mapket/screens/store_selection/store_navigation.dart';
import 'package:mapket/services/database/data_handler_service.dart';
import 'package:mapket/services/local_storage/favourties_service.dart';
import 'package:mapket/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreListEntry extends StatefulWidget {
  final StoreListEntryData data;
  final String id;
  final Image image;
  final num distance;

  const StoreListEntry(
      {Key? key,
      required this.data,
      required this.id,
      required this.image,
      required this.distance})
      : super(key: key);

  @override
  StoreListEntryState createState() => StoreListEntryState();

  StoreListEntryState setState() => StoreListEntryState();
}

/// The entry page for each store
class StoreListEntryState extends State<StoreListEntry> {
  /// on init loads opening times, favourites and products
  @override
  void initState() {
    super.initState();
    loadFavourites()
        .then((value) => loadProducts().then((value) => setState(() {
              _loading = false;
            })))
        .then((value) => setupOpeningTimes());
  }

  DataHandlerService _storageService = getIt<DataHandlerService>();

  TextEditingController editingController = TextEditingController();
  List<ProductData> _products = [];
  bool _loading = true;
  late String _dataKeyFavourites = "store_favourites";
  late SharedPreferences _loadedFavourites;
  late bool _isFavourite = _favourites.contains(widget.id);
  late List<String> _favourites;
  List<ProductData> _listedProducts = [];
  List<String> _openingTimes = [];

  /// loads all products for this store
  Future loadProducts() async {
    final products = _storageService.getAllProductsForStore(widget.id);
    setState(() {
      _products = products!;
      _listedProducts = products;
    });
  }

  /// loads if this store is a favourite
  Future loadFavourites() async {
    _loadedFavourites = await SharedPreferences.getInstance();
    _favourites =
        (_loadedFavourites.getStringList(_dataKeyFavourites) ?? <String>[]);
  }

  /// changes the favourite state on press of the favourite button
  //todo handle favourites in one local storage instead of one list for each store
  Future onFavouritePress() async {
    if (_favourites.contains(widget.id)) {
      setState(() {
        _isFavourite = false;
        _favourites.remove(widget.id);
        _loadedFavourites.setStringList(_dataKeyFavourites, _favourites);
      });
    } else {
      setState(() {
        _isFavourite = true;
        _favourites.add(widget.id);
        _loadedFavourites.setStringList(_dataKeyFavourites, _favourites);
      });
    }
  }

  /// changes icon based on the favourite state
  IconData getIcon() {
    if (_isFavourite) {
      return Icons.star;
    } else {
      return Icons.star_border;
    }
  }

  /// creates opening times with prepend weekday text
  setupOpeningTimes() {
    for (int i = 0; i < widget.data.openingTimes.length; i++) {
      _openingTimes.add(getDate(i) + widget.data.openingTimes[i]);
    }
  }

  /// returns the weekday corresponding to the given input (0-6)
  getDate(int value) {
    switch (value) {
      case 0:
        return AppLocalizations.of(context)!.monday + ": ";
      case 1:
        return AppLocalizations.of(context)!.tuesday + ": ";
      case 2:
        return AppLocalizations.of(context)!.wednesday + ": ";
      case 3:
        return AppLocalizations.of(context)!.thursday + ": ";
      case 4:
        return AppLocalizations.of(context)!.friday + ": ";
      case 5:
        return AppLocalizations.of(context)!.saturday + ": ";
      case 6:
        return AppLocalizations.of(context)!.sunday + ": ";
    }
  }


  /// filters the products for the search bar
  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<ProductData> filteredProducts = [];
      _products.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          filteredProducts.add(item);
        }
      });
      setState(() {
        _listedProducts = filteredProducts;
      });
      return;
    } else {
      setState(() {
        _listedProducts = _products;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold();
    } else {
      return Scaffold(
          appBar: AppBar(
              title: Text(widget.data.name),
              backgroundColor: Colors.blue,
              actions: <Widget>[
                IconButton(
                    icon: Icon(getIcon()),
                    onPressed: () {
                      onFavouritePress();
                    })
              ]),
          body: Center(
              child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: widget.image,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(
                              widget.data.latitude, widget.data.longitude),
                          zoom: 17,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(widget.data.latitude,
                                    widget.data.longitude),
                                // ? TODO: Is container necessary?
                                // ignore: avoid_unnecessary_containers
                                builder: (ctx) => Container(
                                  child: const Icon(Icons.store),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(flex: 1, child: Text("")),
                      Expanded(flex: 1, child: Text(widget.data.name)),
                      Expanded(
                        flex: 1,
                        child: Text(widget.distance.toString() + "m"),
                      ),
                      Expanded(
                          flex: 1,
                          child: DropdownButton<String>(
                            value: DateFormat('EEEE').format(DateTime.now()) +
                                ": " +
                                widget.data
                                    .openingTimes[DateTime.now().weekday - 1]
                                    .toString(),
                            icon: const Icon(Icons.sort),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {},
                            items: _openingTimes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StorePageNavigation(
                                                    id: widget.id))),
                                  },
                              child:
                                  Text(AppLocalizations.of(context)!.navigate)))
                    ],
                  )),
              SizedBox(height: 10),
              Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (value) {
                                  filterSearchResults(value);
                                },
                                controller: editingController,
                                decoration: InputDecoration(
                                    //TODO international
                                    labelText: "Search",
                                    hintText: "Search",
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)))),
                              ))),
                      Expanded(
                          flex: 3,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: _listedProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(_listedProducts[index].name +
                                    " " +
                                    _listedProducts[index].price.toString()),
                                onTap: () {},
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )),
                    ],
                  )),
            ],
          )));
    }
  }
}
