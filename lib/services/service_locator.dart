import 'package:get_it/get_it.dart';
import 'package:mapket/services/database/data_handler_service.dart';
import 'package:mapket/services/database/firestore_map_service.dart';
import 'package:mapket/services/database/firestore_products_service.dart';
import 'package:mapket/services/database/firestore_store_service.dart';
import 'package:mapket/services/database/firestore_image_service.dart';
import 'package:mapket/services/local_storage/favourties_service.dart';
import 'package:mapket/services/local_storage/shopping_list_entry_service.dart';

final getIt = GetIt.instance;

/// sets up each database service as a singleton which then can be accessed in any point of the app
setupServiceLocator() {
  getIt.registerSingleton<FirestoreStoreService>(FirestoreStoreService());
  getIt.registerSingleton<FirestoreProductService>(FirestoreProductService());
  getIt.registerSingleton<FirestoreImageService>(FirestoreImageService());
  getIt.registerSingleton<FavouritesService>(FavouritesService());
  getIt.registerSingleton<ShoppingListEntryService>(ShoppingListEntryService());
  getIt.registerSingleton<DataHandlerService>(DataHandlerService());
  getIt.registerSingleton<FirestoreMapService>(FirestoreMapService());
}