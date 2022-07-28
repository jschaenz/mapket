import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapket/screens/store_selection/store_list_entry.dart';
import 'package:mapket/services/database/data_handler_service.dart';
import 'package:mapket/services/local_storage/favourties_service.dart';
import 'package:mapket/services/service_locator.dart';

class StoreListView extends StatefulWidget {
  final String sort;

  const StoreListView({Key? key, required this.sort}) : super(key: key);

  @override
  StoreListViewState createState() => StoreListViewState();

  StoreListViewState setState() => StoreListViewState();
}

/// The list view inside the store finder page
class StoreListViewState extends State<StoreListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entries = _storageService.getAllStores();

    setState(() {
      _asc = AppLocalizations.of(context)!.sortAscending;
      _desc = AppLocalizations.of(context)!.sortDescending;
      _alph = AppLocalizations.of(context)!.sortAlphabetical;
      _fav = AppLocalizations.of(context)!.sortFavourite;
    });

    /// switch-case not possible here because of non constant applocale
    if (widget.sort == _asc) {
      _entries.sort((a, b) => a.distance.compareTo(b.distance));
      _shownEntries.clear();
      _shownEntries.addAll(_entries);
    } else if (widget.sort == _desc) {
      _entries.sort((a, b) => b.distance.compareTo(a.distance));
      _shownEntries.clear();
      _shownEntries.addAll(_entries);
    } else if (widget.sort == _alph) {
      _entries.sort((a, b) => b.data.name.compareTo(a.data.name));
      _shownEntries.clear();
      _shownEntries.addAll(_entries);
    } else if (widget.sort == _fav) {
      _shownEntries.clear();
      _entries.forEach((entry) {
        if (_favourites.contains(entry.id)) {
          _shownEntries.add(entry);
        }
      });
    }
    _loading = false;
  }

  DataHandlerService _storageService = getIt<DataHandlerService>();
  FavouritesService _favouritesService = getIt<FavouritesService>();

  late String _asc;
  late String _desc;
  late String _alph;
  late String _fav;

  late List<String> _favourites = _favouritesService.getFavourites();

  List<StoreListEntry> _entries = <StoreListEntry>[];
  List<StoreListEntry> _shownEntries = <StoreListEntry>[];
  bool _loading = true;

  /// on store click -> go to the clicked store
  void onTapEntry(int index) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => _entries[index]));
    setState(() {
      _favouritesService.loadFavourites();
      _favourites = _favouritesService.getFavourites();
    });
  }

  /// workaround method, for some reason onInit doesn't get called every time on a new creation if the widget already exists.
  /// just before the items of $entries get placed, they get sorted -> sorted before render, works
  int getItemCount() {
    setState(() {
      _favouritesService.loadFavourites();
      _favourites = _favouritesService.getFavourites();
      _entries = _storageService.getAllStores();
      if (widget.sort == _asc) {
        _entries.sort((a, b) => a.distance.compareTo(b.distance));
        _shownEntries.clear();
        _shownEntries.addAll(_entries);
      } else if (widget.sort == _desc) {
        _entries.sort((a, b) => b.distance.compareTo(a.distance));
        _shownEntries.clear();
        _shownEntries.addAll(_entries);
      } else if (widget.sort == _alph) {
        _entries.sort((a, b) => b.data.name.compareTo(a.data.name));
        _shownEntries.clear();
        _shownEntries.addAll(_entries);
      } else if (widget.sort == _fav) {
        _shownEntries.clear();
        _entries.forEach((entry) {
          if (_favourites.contains(entry.id)) {
            _shownEntries.add(entry);
          }
        });
      }
    });
    _loading = false;
    return _shownEntries.length;
  }

  /// method for handling pulling down on the list to reload data
  Future refresh() async {
    await _favouritesService.loadFavourites();
    //await $storageService.loadAllData();
    setState(() {
      _favourites = _favouritesService.getFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold();
    } else {
      return Scaffold(
        body: Center(
            child:
            RefreshIndicator(
              onRefresh: refresh,
            child:
            ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: getItemCount(),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                      flex: 10, child: Text(_shownEntries[index].data.name)),
                  Expanded(
                      flex: 1,
                      child: _favourites.contains(_shownEntries[index].id)
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border))
                ],
              ),
              subtitle: Text(_shownEntries[index].distance.toString() + "m"),
              onTap: () {
                onTapEntry(index);
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ))),
      );
    }
  }
}
