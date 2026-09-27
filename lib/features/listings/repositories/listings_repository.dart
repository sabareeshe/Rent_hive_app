import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/my_listing.dart';

class ListingsRepository {
  final Dio _dio;
  ListingsRepository(this._dio);

  Future<List<MyListing>> getMyListings() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get('/listings/my-listings');
      final listings = (response.data as List).map((x) => MyListing.fromJson(x)).toList();
      
      await prefs.setString('cached_my_listings', jsonEncode(response.data));
      return listings;
    } catch (e) {
      final cached = prefs.getString('cached_my_listings');
      if (cached != null) {
        return (jsonDecode(cached) as List).map((x) => MyListing.fromJson(x)).toList();
      }
      rethrow;
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

  Future<void> addListing(MyListing listing, {List<String>? imagePaths}) async {
    FormData? formData;
    
    if (imagePaths != null && imagePaths.isNotEmpty) {
      formData = FormData.fromMap({
        'data': jsonEncode(listing.toJson()),
      });
      for (var path in imagePaths) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
      }
    }

    await _dio.post('/listings', data: formData ?? listing.toJson());
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
