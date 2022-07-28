import 'package:flutter/material.dart';

/// Data Model for a Store
@immutable
// ignore: must_be_immutable
class StoreListEntryData {
  final String name;
  final double latitude;
  final double longitude;
  final List<String> openingTimes;
  bool isFavourite;

  StoreListEntryData(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.openingTimes,
      required this.isFavourite});

  StoreListEntryData.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          latitude: json['latitude']! as double,
          longitude: json['longitude']! as double,
          openingTimes: (json['openingTimes']! as List).cast<String>(),
          isFavourite: json['isFavourite']! as bool,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'openingTimes': openingTimes,
      'isFavourite': isFavourite,
    };
  }
}
