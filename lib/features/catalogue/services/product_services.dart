import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../products/models/product_model.dart';
import '../data/initial_products.dart';

class ProductServices {
  ProductServices({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static bool _hasCheckedSeed = false;

  Future<void> seedInitialProductsIfEmpty() async {
    if (_hasCheckedSeed) return;
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final product in initialCatalogueProducts) {
          final docRef = _firestore
              .collection('products')
              .doc((product['id'] ?? product['slug']) as String);
          batch.set(docRef, product);
        }
        await batch.commit();
        log(
          'Seeded ${initialCatalogueProducts.length} initial products to Firestore.',
        );
      }
      _hasCheckedSeed = true;
    } catch (e) {
      log('Notice during seed products check: $e');
    }
  }

  Future<List<ProductModel>> fetchProducts({
    int page = 0,
    int limit = 10,
    String search = '',
    String category = 'All Gifts',
    int? minPrice,
    int? maxPrice,
    List<String> occasions = const [],
    List<String> customisations = const [],
  }) async {
    try {
      await seedInitialProductsIfEmpty();

      final snapshot = await _firestore.collection('products').get();

      List<Map<String, dynamic>> allData = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id') ||
            data['id'] == null ||
            data['id'].toString().isEmpty) {
          data['id'] = doc.id;
        }
        return data;
      }).toList();

      // If Firestore had no documents and seed couldn't commit (e.g. offline/rules),
      // fall back to in-memory initialCatalogueProducts so the app remains fully functional.
      if (allData.isEmpty) {
        allData = initialCatalogueProducts.map((item) {
          final copy = Map<String, dynamic>.from(item);
          copy['id'] = copy['slug'];
          return copy;
        }).toList();
      }

      // Sort by sort_order
      allData.sort((a, b) {
        final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
        final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
        return aOrder.compareTo(bOrder);
      });

      // Filter active products
      List<ProductModel> products = allData
          .where((data) => data['is_active'] != false)
          .map((data) => ProductModel.fromJson(data))
          .toList();

      // Filter by category
      if (category != 'All Gifts') {
        products = products
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      // Filter by search query
      if (search.trim().isNotEmpty) {
        final term = search.trim().toLowerCase();
        products = products
            .where((p) => p.name.toLowerCase().contains(term))
            .toList();
      }

      // Filter by price range overlap
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }

      // Filter by occasions overlap
      if (occasions.isNotEmpty) {
        products = products
            .where((p) => occasions.any((occ) => p.occasions.contains(occ)))
            .toList();
      }

      // Filter by customisations overlap
      if (customisations.isNotEmpty) {
        products = products
            .where(
              (p) => customisations.any((c) => p.customisations.contains(c)),
            )
            .toList();
      }

      // Pagination
      final from = page * limit;
      if (from >= products.length) {
        return [];
      }
      final to = (from + limit > products.length)
          ? products.length
          : from + limit;

      final pagedResult = products.sublist(from, to);
      log(
        'products: page $from, limit $limit, returned: ${pagedResult.length}',
      );
      return pagedResult;
    } on FirebaseException catch (error, stackTrace) {
      log('Firebase product query error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected product query error: $error, $stackTrace');
      rethrow;
    }
  }
}
