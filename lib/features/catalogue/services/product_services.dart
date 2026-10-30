import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductServices {
  ProductServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductModel>> fetchProducts({
    int page = 0,
    int limit = 8,
    String search = '',
    String category = 'All Gifts',
    int? minPrice,
    int? maxPrice,
    List<String> occasions = const [],
    List<String> customisations = const [],
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var query = _client.from('products').select().eq('is_active', true);

      if (category != 'All Gifts') {
        query = query.eq('category', category);
      }

      if (search.trim().isNotEmpty) {
        query = query.ilike('name', '%${search.trim()}%');
      }

      // Price ranges must overlap the selected price range.
      if (minPrice != null) {
        query = query.gte('max_price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('min_price', maxPrice);
      }

      // Match at least one selected occasion.
      if (occasions.isNotEmpty) {
        query = query.overlaps('occasions', occasions);
      }

      // Match at least one selected customisation.
      if (customisations.isNotEmpty) {
        query = query.overlaps('customisations', customisations);
      }

      final response = await query.order('sort_order').range(from, to);

      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase product query error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected product query error: $error, $stackTrace');

      rethrow;
    }
  }
}
