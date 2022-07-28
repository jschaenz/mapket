import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapket/resources/data_models/store_list_data.dart';


/// service for getting stores from the DB
class FirestoreStoreService {
  Future<QuerySnapshot<StoreListEntryData>> getAllStores() {
    return FirebaseFirestore.instance
        .collection("stores")
        .withConverter<StoreListEntryData>(
          fromFirestore: (snapshots, _) =>
              StoreListEntryData.fromJson(snapshots.data()!),
          toFirestore: (store, _) => store.toJson(),
        )
        .get();
  }

  FirestoreStoreService();
}
