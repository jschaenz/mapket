import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapket/screens/store_selection/store_list_entry.dart';
import 'package:mapket/services/database/data_handler_service.dart';
import 'package:mapket/services/service_locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreMapView extends StatefulWidget {
  const StoreMapView({Key? key}) : super(key: key);

  @override
  StoreMapViewState createState() => StoreMapViewState();
}

/// the map view of all stores
class StoreMapViewState extends State<StoreMapView> {
  /// on init, locates the device and loads all stores
  @override
  void initState() {
    super.initState();
    locateDevice()
        .then((value) => loadStores())
        .then((value) => setState(() {
              _loading = false;
            }));
  }

  DataHandlerService _storageService = getIt<DataHandlerService>();

  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(4, 4);
  double _zoom = 7;
  List<LatLng> _latLngList = [];
  Map<Marker, StoreListEntry> _stores = {};
  List<Marker> _markers = [];
  bool _loading = true;

  /// loads all stores, adds them as markers to the map
  loadStores() async {
    final stores = _storageService.getAllStores();
    print(stores);

    for (final store in stores) {
      final latLong = LatLng(store.data.latitude, store.data.longitude);
      final marker = Marker(
        point: latLong,
        width: 30,
        height: 30,
        builder: (context) => const Icon(
          Icons.store,
          size: 30,
          color: Colors.blueAccent,
        ),
      );
      setState(() {
        _latLngList.add(latLong);
        _markers.add(marker);
        _stores[marker] = store;
      });
    }
  }

  /// locates the device and adds the current location as a marker on the map
  Future locateDevice() async {
    final position = _storageService.getLocation();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        point: _currentLocation,
        builder: (context) => const Icon(
          Icons.arrow_drop_down,
          size: 30,
          color: Colors.redAccent,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold();
    } else {
      return Scaffold(
          body: Center(
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation,
            bounds: LatLngBounds.fromPoints(_latLngList),
            zoom: _zoom,
            plugins: [
              MarkerClusterPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
              minZoom: 2,
              maxZoom: 25,
              backgroundColor: Colors.black,
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerClusterLayerOptions(
              maxClusterRadius: 190,
              disableClusteringAtZoom: 16,
              size: const Size(50, 50),
              fitBoundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: _markers,
              polygonOptions: const PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              popupOptions: PopupOptions(
                  popupSnap: PopupSnap.markerTop,
                  popupController: _popupController,
                  popupBuilder: (_, marker) => Container(
                        child: ElevatedButton(
                          onPressed: () {
                            if (marker.point != _currentLocation) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => _stores[marker]!));
                            }
                          },
                          child: marker.point != _currentLocation
                              ? Text(_stores[marker]!.data.name)
                              : Text(AppLocalizations.of(context)!.currentLocation),
                        ),
                      )),
              builder: (context, markers) {
                return Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                  child: Text('${markers.length}'),
                );
              },
            ),
          ],
        ),
      ));
    }
  }
}
