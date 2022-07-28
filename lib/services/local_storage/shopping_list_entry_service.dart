import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListEntryService{

  final String dataKeyShoppingList = "shopping_list";

  /// Loads the shopping list from local memory.
  ///
  /// The shopping list gets accessed using shared preferences and decoded from
  /// a JSON string.
  Future<Map<String, dynamic>> loadShoppingList() async {
    final pref = await SharedPreferences.getInstance();
    String? encodedMap = (pref.getString(this.dataKeyShoppingList) ?? "");
    return json.decode(encodedMap) ?? Map<String, dynamic>();
  }

  /// Saves the shopping list to local memory.
  ///
  /// The shopping list gets converted to a JSON string which is written to
  /// local memory using shared preferences.
  Future<void> saveShoppingList(Map<String, dynamic> mapToSave) async {
    final pref = await SharedPreferences.getInstance();
    String encodedMap = json.encode(mapToSave);
    pref.setString(this.dataKeyShoppingList, encodedMap);
  }
  
  ShoppingListEntryService();
}