import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMapService {
  DocumentReference getUserInputMapNameDocRef(String userNameInput) {
    return FirebaseFirestore.instance
        .collection("savedMaps")
        .doc(userNameInput);
  }

  void updateMaps(String path, Map<String, String> input) {
    FirebaseFirestore.instance.collection("savedMaps").doc(path).update(input);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMapsQuerySnapshotAsStream() {
    return FirebaseFirestore.instance.collection("savedMaps").snapshots();
  }

  FirestoreMapService();
}
