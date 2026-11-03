import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/my_listing.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ListingsRepository {
  final Dio _dio;
  ListingsRepository(this._dio);

  Future<List<MyListing>> getMyListings() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_my_listings');
    List<MyListing> localListings = [];
    if (cached != null) {
      try {
        localListings = (jsonDecode(cached) as List).map((x) => MyListing.fromJson(x)).toList();
      } catch (_) {}
    }

    try {
      final response = await _dio.get('/listings/my-listings');
      final serverListings = (response.data as List).map((x) => MyListing.fromJson(x)).toList();
      
      // Merge: server listings + local listings not yet synced
      final serverIds = serverListings.map((e) => e.id).toSet();
      final combined = [
        ...serverListings,
        ...localListings.where((l) => !serverIds.contains(l.id)),
      ];

      await prefs.setString('cached_my_listings', jsonEncode(combined.map((e) => e.toJson()..['_id'] = e.id).toList()));
      return combined;
    } catch (e) {
      if (localListings.isNotEmpty) {
        return localListings;
      }
      return [];
    }
  }

  Future<List<MyListing>> getAllListings({String? search, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;

      final response = await _dio.get('/listings', queryParameters: queryParams);
      return (response.data as List).map((x) => MyListing.fromJson(x)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MyListing> getListingById(String id) async {
    try {
      final response = await _dio.get('/listings/$id');
      return MyListing.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<MyListing> addListing(MyListing listing, {List<String>? imagePaths}) async {
    FormData? formData;
    
    if (imagePaths != null && imagePaths.isNotEmpty) {
      try {
        formData = FormData.fromMap({
          'data': jsonEncode(listing.toJson()),
        });
        for (var path in imagePaths) {
          if (path.startsWith('http://') || path.startsWith('https://')) {
            continue;
          }
          if (kIsWeb) {
            try {
              final bytes = await XFile(path).readAsBytes();
              formData.files.add(MapEntry(
                'images',
                MultipartFile.fromBytes(bytes, filename: 'image.jpg'),
              ));
            } catch (_) {
              final response = await Dio().get(
                path,
                options: Options(responseType: ResponseType.bytes),
              );
              formData.files.add(MapEntry(
                'images',
                MultipartFile.fromBytes(response.data, filename: 'image.jpg'),
              ));
            }
          } else {
            formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
          }
        }
      } catch (e) {
        formData = null;
      }
    }

    Response response;
    try {
      response = await _dio.post('/listings', data: formData ?? listing.toJson());
    } catch (e) {
      if (formData != null) {
        response = await _dio.post('/listings', data: listing.toJson());
      } else {
        rethrow;
      }
    }

    MyListing created = listing;
    if (response.data is Map<String, dynamic>) {
      created = MyListing.fromJson(response.data);
    }

    // Persist to local cache immediately so it never disappears on refresh
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_my_listings');
      List<dynamic> existingList = [];
      if (cachedStr != null) {
        try {
          existingList = jsonDecode(cachedStr) as List;
        } catch (_) {}
      }
      final updatedList = [
        created.toJson()..['_id'] = created.id,
        ...existingList.where((item) => (item['_id'] ?? item['id']) != created.id && (item['_id'] ?? item['id']) != listing.id)
      ];
      await prefs.setString('cached_my_listings', jsonEncode(updatedList));
    } catch (_) {}

    return created;
  }

  Future<void> updateListing(MyListing updatedListing) async {
    await _dio.put('/listings/${updatedListing.id}', data: updatedListing.toJson());
  }

  Future<void> deleteListing(String id) async {
    await _dio.delete('/listings/$id');
  }

  Future<void> pauseListing(String id) async {
    await _dio.put('/listings/$id', data: {'status': 'paused'});
  }

  Future<void> resumeListing(String id) async {
    await _dio.put('/listings/$id', data: {'status': 'available'});
  }
}
