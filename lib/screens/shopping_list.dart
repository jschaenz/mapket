import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mapket/resources/data_models/product_family.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:mapket/services/local_storage/shopping_list_entry_service.dart';
import 'package:mapket/services/service_locator.dart';


class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  ShoppingListEntryService shoppinglistStorageService =
      getIt<ShoppingListEntryService>();
  Map<String, dynamic> shoppingList = <String, int>{};
  List<String> itemSelection =
      EnumToString.toList(ProductFamily.values, camelCase: true);
  late String? selectedItem = itemSelection[0];

  // Definition of button sizes so each button is the same size
  // TODO remove fixed sizes -> dynamic sizing
  final Size _buttonSizeMin = Size(300, 40);
  final Size _buttonSizeMax = Size(350, 40);

  /// Sets the shopping list.
  ///
  /// This method is used in the constructor when initializing the
  /// shoppingList screen.
  Future<void> _setShoppingList() async {
    Map<String, dynamic> loadedMap =
        await shoppinglistStorageService.loadShoppingList();
    setState(() {
      this.shoppingList = loadedMap;
    });
  }

  /// Add the contents of the textinput to the list of items
  ///
  /// Checks if an element present in the list. If not it will be added.
  /// Otherwise nothing will happen.
  Future<void> addItemToList() async {
    Map<String, dynamic> loadedList =
        await shoppinglistStorageService.loadShoppingList();

    setState(() {
      shoppingList = loadedList;
      if (shoppingList.containsKey(this.selectedItem)) {
        int currentValue = shoppingList[this.selectedItem] ?? 1;
        shoppingList[this.selectedItem.toString()] = currentValue + 1;
      } else {
        shoppingList[this.selectedItem.toString()] = 1;
      }
    });

    shoppinglistStorageService.saveShoppingList(shoppingList);
  }

  /// Remove the selected item from the shopping list
  ///
  /// For each method call, the quantity of the currently selected item will
  /// be reduced by one. If the quantity reaches 0, the item is removed
  /// entirely.
  Future<void> removeItemFromList() async {
    Map<String, dynamic> loadedMap =
        await shoppinglistStorageService.loadShoppingList();

    setState(() {
      this.shoppingList = loadedMap;
      if (this.shoppingList.containsKey(this.selectedItem)) {
        // get quantity
        int currentQuantity = shoppingList[this.selectedItem] - 1;

        if (currentQuantity == 0) {
          this.shoppingList.remove(this.selectedItem.toString());
        } else {
          this.shoppingList[this.selectedItem.toString()] = currentQuantity;
        }
      }
    });

    shoppinglistStorageService.saveShoppingList(this.shoppingList);
  }

  /// Removes all items from the shopping list
  void clearEntireList() async {
    setState(() {
      this.shoppingList = <String, dynamic>{};
    });

    shoppinglistStorageService.saveShoppingList(this.shoppingList);
  }

  /// Loads the state of the shopping list on screen init
  @override
  void initState() {
    super.initState();
    _setShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.shopping_list),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: DropdownButton<String>(
              value: selectedItem,
              items: itemSelection
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: (String? _value) {
                setState(() {
                  selectedItem = _value;
                });
              },
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: this._buttonSizeMin,
                maximumSize: this._buttonSizeMax,
              ),
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () {
                addItemToList();
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: this._buttonSizeMin,
                maximumSize: this._buttonSizeMax,
              ),
              child: Text(AppLocalizations.of(context)!.remove),
              onPressed: () {
                removeItemFromList();
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: this._buttonSizeMin,
                maximumSize: this._buttonSizeMax,
              ),
              child: Text(AppLocalizations.of(context)!.clear),
              onPressed: () {
                clearEntireList();
              }),
          Expanded(
            //TODO make scrollable
            child: DataTable(
                horizontalMargin: 40.0,
                columns: <DataColumn>[
                  DataColumn(
                      label:
                          Text(AppLocalizations.of(context)!.product_category)),
                  DataColumn(
                      label: Text(AppLocalizations.of(context)!.quantity),
                      numeric: true),
                ],
                rows: shoppingList.entries
                    .map((e) => DataRow(cells: <DataCell>[
                          DataCell(Text(e.key.toString())),
                          DataCell(Text(e.value.toString())),
                        ]))
                    .toList()),
          ),
        ],
      ),
    );
  }
}
