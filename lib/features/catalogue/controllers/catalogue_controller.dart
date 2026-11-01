import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/features/catalogue/services/product_services.dart';

import '../../products/models/product_model.dart';

class CatalogueController extends GetxController {
  CatalogueController({ProductServices? repository})
    : _repository = repository ?? ProductServices();

  final ProductServices _repository;

  final searchController = TextEditingController();

  static const int pageSize = 10;

  final categories = [
    'All Gifts',
    'Drinkware',
    'Apparel',
    'Work Essentials',
    'Wellness',
  ];

  final occasionsList = [
    'Employee Onboarding',
    'Corporate Diwali Gifting',
    'New Year Gifts',
    'Client and Vendor Gifting',
    'Events and Trade Shows',
    'Employee Recognition',
  ];

  final customisationOptions = [
    'Logo printing',
    'Laser engraving',
    'Name personalisation',
  ];

  final budgetOptions = [
    'All Budgets',
    'Under ₹500',
    '₹500 – ₹1,500',
    '₹1,500 – ₹3,000',
    'Above ₹3,000',
  ];

  RxList<ProductModel> trendingProducts = <ProductModel>[].obs;
  RxList<ProductModel> bannerProducts = <ProductModel>[].obs;
  RxList<ProductModel> mostRequestedProducts = <ProductModel>[].obs;
  RxList<ProductModel> topProducts = <ProductModel>[].obs;

  final products = <ProductModel>[].obs;

  final selectedCategory = 'All Gifts'.obs;
  final selectedOccasions = <String>[].obs;
  final selectedCustomisations = <String>[].obs;
  final selectedBudgetIndex = 0.obs;
  final isDashboardLoading = false.obs;
  final errorDashboard = false.obs;
  final isLoading = false.obs;
  final error = false.obs;

  Timer? _searchDebounce;

  int? get minPrice {
    switch (selectedBudgetIndex.value) {
      case 1:
        return 0;
      case 2:
        return 500;
      case 3:
        return 1500;
      case 4:
        return 3000;
      default:
        return null;
    }
  }

  int? get maxPrice {
    switch (selectedBudgetIndex.value) {
      case 1:
        return 500;
      case 2:
        return 1500;
      case 3:
        return 3000;
      default:
        return null;
    }
  }

  bool get hasActiveFilters =>
      selectedCategory.value != 'All Gifts' ||
      selectedOccasions.isNotEmpty ||
      selectedCustomisations.isNotEmpty ||
      selectedBudgetIndex.value != 0;

  @override
  void onInit() {
    super.onInit();
    loadDashBoard();
    loadTopProducts();
  }

  Future loadDashBoard() async {
    try {
      isDashboardLoading.value = true;
      errorDashboard.value = false;
      await Future.wait([
        loadBannerProducts(),
        loadMostRequestedProducts(),
        loadProducts(),
      ]);
      isDashboardLoading.value = false;
      errorDashboard.value = false;
    } catch (e) {
      log('Error Dashboard $e');
      isDashboardLoading.value = false;
      errorDashboard.value = true;
    } finally {
      isDashboardLoading.value = false;
    }
  }

  Future<void> loadProducts({bool reset = true}) async {
    if (isLoading.value) return;

    products.clear();
    error.value = false;
    isLoading.value = true;

    try {
      final result = await _repository.fetchProducts(
        search: searchController.text.trim(),
        category: selectedCategory.value,
        minPrice: minPrice,
        maxPrice: maxPrice,
        occasions: selectedOccasions.toList(),
        customisations: selectedCustomisations.toList(),
      );

      products.assignAll(result);

      error.value = false;
    } catch (e) {
      error.value = true;
      debugPrint('Catalogue error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBannerProducts() async {
    try {
      final result = await _repository.fetchProducts(category: 'Drinkware');

      trendingProducts.value = List.from(result);

      bannerProducts.value = List.from(result);
      bannerProducts.removeWhere(
        (element) =>
            element.imageUrl == null || element.imageUrl?.isEmpty == true,
      );
      log('banner images $bannerProducts');
    } catch (e) {
      debugPrint('Error load banner products error: $error');
    }
  }

  Future<void> loadMostRequestedProducts() async {
    try {
      final result = await _repository.fetchProducts(category: 'Apparel');

      mostRequestedProducts.value = List.from(result);

      log('resp banner $mostRequestedProducts');
      error.value = false;
    } catch (e) {
      debugPrint('Erro load most requested products error: $error');
    }
  }

  Future<void> loadTopProducts() async {
    try {
      final result = await _repository.fetchProducts(
        category: 'Work Essentials',
      );

      topProducts.value = List.from(result);

      log('resp top products $products');
    } catch (e) {
      debugPrint('Erro load most requested products error: $error');
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    loadProducts();
  }

  void selectBudget(int index) {
    selectedBudgetIndex.value = index;
    loadProducts();
  }

  void toggleOccasion(String occasion) {
    if (selectedOccasions.contains(occasion)) {
      selectedOccasions.remove(occasion);
    } else {
      selectedOccasions.add(occasion);
    }
    loadProducts();
  }

  void toggleCustomisation(String value) {
    if (selectedCustomisations.contains(value)) {
      selectedCustomisations.remove(value);
    } else {
      selectedCustomisations.add(value);
    }

    loadProducts();
  }

  void searchProducts(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => loadProducts(),
    );
  }

  void clearFilters() {
    selectedCategory.value = 'All Gifts';
    selectedOccasions.clear();
    selectedCustomisations.clear();
    selectedBudgetIndex.value = 0;
    searchController.clear();
    _searchDebounce?.cancel();
    loadProducts();
  }

  Future<void> loadMore() async {
    await loadProducts(reset: false);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
