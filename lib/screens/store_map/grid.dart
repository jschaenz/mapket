import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapket/services/database/firestore_map_service.dart';
import 'package:mapket/services/service_locator.dart';

class Grid extends StatefulWidget {
  const Grid({Key? key}) : super(key: key);

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  final _textController = TextEditingController();
  final _saveController = TextEditingController();
  String userInput = "5";
  String userNameInput = "";
  int entrance = -1;

  var myColors = List<Color>.filled(25, Colors.grey);

  FirestoreMapService mapService = getIt<FirestoreMapService>();

  /// builds the grid with the user input
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.map_builder),
      ),
      // ? FIXME: Is container necessary?
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .number_of_rows_and_columns,
                    suffixIcon: IconButton(
                        onPressed: () {
                          _textController.clear();
                        },
                        icon: const Icon(Icons.clear))),
                keyboardType: TextInputType.number,
                maxLength: 2,
                controller: _textController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
                ],
              ),
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isEmpty){
                    return;
                  }
                  setState(() {
                    userInput = _textController.text;
                    var colorList = List<Color>.filled(
                        int.parse(userInput) * int.parse(userInput),
                        Colors.grey);
                    myColors = colorList;
                    if (int.parse(userInput) > 30) {
                      userInput = "30";
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.number_range,
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                    if (int.parse(userInput) < 5) {
                      myColors = List<Color>.filled(25, Colors.grey);
                      userInput = "5";
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Number should be between 5 and 30\n\nSet to min of 5",
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  });
                },
                color: Colors.blue,
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
              _buildMapBody(),
              TextField(
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.map_name,
                    suffixIcon: IconButton(
                        onPressed: () {
                          _saveController.clear();
                        },
                        icon: const Icon(Icons.clear))),
                keyboardType: TextInputType.name,
                maxLength: 20,
                controller: _saveController,
              ),
              MaterialButton(
                onPressed: () {
                  setState(
                    () {
                      userNameInput = _saveController.text;
                      _saveGrid();
                    },
                  );
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// returns a grid with the size of the user input^2 and some border decorations
  Widget _buildMapBody() {
    int gridLength = int.parse(userInput);
    return Column(children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0,
        child: InteractiveViewer(
          child: Container(
            padding: const EdgeInsets.all(2.0),
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0)),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridLength,
                ),
                itemCount: gridLength * gridLength,
                itemBuilder: (context, index) {
                  return _buildGridItems(context, index);
                }),
          ),
        ),
      ),
    ]);
  }

  /// returns the grid items with the necessary color and decoration
  Widget _buildGridItems(BuildContext context, int index) {
    // ? FIXME: Is container necessary?
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.2),
          ),
          child: Container(
            decoration: BoxDecoration(color: myColors[index]),
          ),
        ),
        onTap: () {
          _selectTile(index);
        },
        onLongPress: () {
          _selectEntrance(index);
        },
      ),
    );
  }

  /// selects a tile to change the color of it
  _selectTile(int index) {
    setState(() {
      if (entrance == index) {
        return;
      } else if (myColors[index] == Colors.brown) {
        myColors[index] = Colors.grey;
      } else {
        myColors[index] = Colors.brown;
      }
    });
  }

  /// select the entrance with its specific color
  _selectEntrance(int index) {
    setState(() {
      if (entrance < 0 && myColors[index] == Colors.grey) {
        entrance = index;
        myColors[index] = Colors.green;
      } else if (entrance >= 0 && myColors[index] == Colors.green) {
        entrance = -1;
        myColors[index] = Colors.grey;
      }
    });
  }

  
  /// saves the grid to the firestore database in a specific format and with the users choice of naming
  _saveGrid() {
    String colorValues = "";
    // ? FIXME: Research on method to fix the codesmell
    // ignore: avoid_function_literals_in_foreach_calls
    myColors.forEach((element) {
      colorValues += element.value.toString();
      colorValues += ";";
    });
    String products = "";
    myColors.forEach((element) {
      products += ";";
    });

    /// fetch doc reference from service
    DocumentReference documentReference =
        mapService.getUserInputMapNameDocRef(userNameInput);

    /// json format for the saved maps
    Map<String, String> maps = {
      "mapTitle": userNameInput,
      "colorValues": colorValues,
      "products": products
    };

    /// if the map name already exists, a alert dialog pops up
    documentReference.get().then((docData) => {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: docData.exists
                      ? Text(
                          AppLocalizations.of(context)!.name_exists,
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          AppLocalizations.of(context)!.map_saved,
                          textAlign: TextAlign.center,
                        ),
                  actions: [
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.ok),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              }),
          if (!docData.exists) {documentReference.set(maps)}
        });
  }
}
