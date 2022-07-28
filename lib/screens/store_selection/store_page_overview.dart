import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapket/screens/store_selection/store_list_view.dart';

import 'store_map_view.dart';

class StorePageOverview extends StatefulWidget {
  const StorePageOverview({Key? key}) : super(key: key);

  @override
  StorePageOverviewState createState() => StorePageOverviewState();

  StorePageOverviewState setState() => StorePageOverviewState();
}

/// overview of all stores, store finder page
class StorePageOverviewState extends State<StorePageOverview> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _content =
          StoreListView(sort: AppLocalizations.of(context)!.sortAscending);
      _dropdownSortValue = AppLocalizations.of(context)!.sortAscending;
      _loading = false;
    });
  }

  IconData _displayedIcon = Icons.map;
  bool _sortIsVisible = true;
  late String _dropdownSortValue;
  StoreMapView _mapview = const StoreMapView();
  late Widget _content;
  bool _loading = true;

  /// handles changing from map view to list view
  void onDisplayChange() {
    if (_displayedIcon == Icons.map) {
      setState(() {
        _displayedIcon = Icons.list_alt;
        _sortIsVisible = false;
        _content = _mapview;
      });
    } else {
      setState(() {
        _displayedIcon = Icons.map;
        _sortIsVisible = true;
        _content = StoreListView(sort: _dropdownSortValue);
      });
    }
  }

  /// handles changes in sorting, creates a new StoreListView with the correct sort
  void onSortChanged(String? newValue) {
    setState(() {
      _dropdownSortValue = newValue!;
      _content = StoreListView(sort: newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.title,
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            Visibility(
                visible: _sortIsVisible,
                child: DropdownButton<String>(
                  value: _dropdownSortValue,
                  icon: const Icon(Icons.sort),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    onSortChanged(newValue);
                  },
                  items: <String>[
                    AppLocalizations.of(context)!.sortAscending,
                    AppLocalizations.of(context)!.sortDescending,
                    AppLocalizations.of(context)!.sortAlphabetical,
                    AppLocalizations.of(context)!.sortFavourite
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )),
            IconButton(
                icon: Icon(_displayedIcon),
                onPressed: () {
                  onDisplayChange();
                })
          ],
        ),
        body: Center(
          child: _content,
        ),
      );
    }
  }

}
