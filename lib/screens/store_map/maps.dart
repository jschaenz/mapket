import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapket/screens/store_map/map_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {

  //TODO service
  final Stream<QuerySnapshot> maps =
      FirebaseFirestore.instance.collection("savedMaps").snapshots();

  /// loads the available maps in a list to select, can be deleted from the database
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.maps),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: maps,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(AppLocalizations.of(context)!.something_error);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(AppLocalizations.of(context)!.loading);
            }

            final data = snapshot.requireData;

            return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MapDetails(id: index, data: data)));
                        });
                      },
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  //TODO internationalize
                                  "Are you sure you want to delete ${data.docs[index]["mapTitle"]}?",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(AppLocalizations.of(context)!
                                        .confirm,textAlign: TextAlign.left,),
                                    onPressed: () {
                                      data.docs[index].reference.delete();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      //TODO internationalize
                                      "cancel",
                                      textAlign: TextAlign.right,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text("${data.docs[index]["mapTitle"]}"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
