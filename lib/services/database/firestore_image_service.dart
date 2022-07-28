import 'package:firebase_storage/firebase_storage.dart';

/// service for getting images from firestore for a specific store
class FirestoreImageService {
  Future<String> getImage(String storeId) {
    return FirebaseStorage.instance
        .ref()
        .child("stores")
        .child(storeId + ".png")
        .getDownloadURL();
  }

  FirestoreImageService();
}
