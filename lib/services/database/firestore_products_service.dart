import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapket/resources/data_models/product_data.dart';

/// service for getting products for a certain store from the DB
class FirestoreProductService {
  Future<QuerySnapshot<ProductData>> getAllProductsForStore(String id) {
    return FirebaseFirestore.instance
        .collection("stores")
        .doc(id)
        .collection("products")
        .withConverter<ProductData>(
          fromFirestore: (snapshots, _) =>
              ProductData.fromJson(snapshots.data()!),
          toFirestore: (product, _) => product.toJson(),
        )
        .get();
  }

  FirestoreProductService();
}
