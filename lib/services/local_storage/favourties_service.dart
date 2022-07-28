import 'package:shared_preferences/shared_preferences.dart';

class FavouritesService{
  late String dataKeyFavourites = "store_favourites";

  late List<String> favourites;

  late SharedPreferences loadedFavourites;

  /// loads the favourited stores from local storage
  Future loadFavourites() async {
    loadedFavourites = await SharedPreferences.getInstance();
    favourites =
    (loadedFavourites.getStringList(dataKeyFavourites) ?? <String>[]);
  }


  /// returns the last loaded favourited stores from local storage
  List<String> getFavourites(){
    return favourites;
  }

  FavouritesService();
}