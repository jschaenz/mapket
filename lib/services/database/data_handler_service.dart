import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapket/resources/data_models/product_data.dart';
import 'package:mapket/screens/store_selection/store_list_entry.dart';
import 'package:mapket/services/database/firestore_image_service.dart';
import 'package:mapket/services/database/firestore_products_service.dart';
import 'package:mapket/services/database/firestore_store_service.dart';
import 'package:mapket/services/local_storage/favourties_service.dart';
import 'package:mapket/services/service_locator.dart';
import 'package:latlong2/latlong.dart';


/// service for loading the firestore items and exposing them to the rest of the app
/// all data gets loaded on startup
class DataHandlerService {
  FirestoreProductService productStorageService =
      getIt<FirestoreProductService>();
  FirestoreStoreService storeStorageService = getIt<FirestoreStoreService>();
  FirestoreImageService imageService = getIt<FirestoreImageService>();
  FavouritesService favouritesService = getIt<FavouritesService>();

  List<StoreListEntry> $stores = [];
  Map<String, List<ProductData>> $products = {};
  Map<String, Image> $images = {};
  late Position $position;

  List<StoreListEntry> getAllStores() {
    return $stores;
  }

  List<ProductData>? getAllProductsForStore(String storeId) {
    return $products[storeId];
  }

  Image? getImageForStore(String storeId) {
    return $images[storeId];
  }

  Position getLocation() {
    return $position;
  }

  /// fetches all stores from the DB using the service
  Future fetchAllStores() async {
    final stores = await storeStorageService.getAllStores();
    for (final doc in stores.docs) {
      final url = await imageService.getImage(doc.id);
      final dist = const Distance().as(
          LengthUnit.Meter,
          LatLng(doc.data().latitude, doc.data().longitude),
          LatLng($position.latitude, $position.longitude));

      $stores.add(StoreListEntry(
        id: doc.id,
        data: doc.data(),
        image: Image.network(url),
        distance: dist,
      ));
    }
  }

  /// fetches all products from all stores from the DB using the service
  Future fetchProductsByStoreId(String storeId) async {
    final products =
        await productStorageService.getAllProductsForStore(storeId);
    List<ProductData> productData = [];
    for (final doc in products.docs) {
      final data = doc.data();
      productData.add(ProductData(
          name: data.name,
          location: data.location,
          family: data.family,
          price: data.price));
    }
    $products[storeId] = productData;
  }

  /// fetches all images from all stores from the DB using the service
  Future fetchImageByStoreId(String storeId) async {
    final url = await imageService.getImage(storeId);
    $images[storeId] = Image.network(url);
  }

  /// fetches the current device location
  Future fetchLocation() async {
    await Geolocator.requestPermission();
    $position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }


  /// fetches all the data from the db and writes it into the class variables
  Future loadAllData() async {
    final time = DateTime.now().millisecondsSinceEpoch;
    await Geolocator.requestPermission();
    await fetchLocation();
    await fetchAllStores();
    for (final store in $stores) {
      await fetchProductsByStoreId(store.id);
      await fetchImageByStoreId(store.id);
    }
    favouritesService.loadFavourites();
    print(
        "Data Loading took ${DateTime.now().millisecondsSinceEpoch - time}ms");
  }

  DataHandlerService();
}
