import 'package:flutter/cupertino.dart';

/// Data model for a Product
@immutable
class ProductData {
  final String name;
  final num price;
  final String location;
  final String family;

  const ProductData(
      {required this.name,
      required this.price,
      required this.location,
      required this.family});

  ProductData.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          price: json['price']! as num,
          location: json['location']! as String,
          family: json['family']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'price': price,
      'location': location,
      'family': family,
    };
  }
}
