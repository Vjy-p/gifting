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
  final isLastPage = false.obs;
  final page = 0.obs;
  static const int pageSize = 10;
  RxBool hasActiveFilters = false.obs;

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
      products.clear();
      isLastPage.value = false;
      page.value = 0;
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

  Future<void> loadProducts({bool reset = true, String search = ''}) async {
    if (isLoading.value || isLastPage.value) return;

    if (products.isEmpty || products.length < pageSize || reset) {
      products.clear();
      error.value = false;
      isLoading.value = true;
      page.value = 0;
    }

    try {
      final result = await _repository.fetchProducts(
        page: page.value,
        limit: pageSize,
        search: search.trim(),
        category: selectedCategory.value,
        minPrice: minPrice,
        maxPrice: maxPrice,
        occasions: selectedOccasions.toList(),
        customisations: selectedCustomisations.toList(),
      );
      page.value++;

      if (result.length < pageSize) {
        isLastPage.value = true;
      }

      products.addAll(result);

      isLoading.value = false;
      error.value = false;
    } catch (e) {
      isLoading.value = false;
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
    isLastPage.value = false;
    products.clear();
    hasActiveFilters.value =
        selectedCategory.value != 'All Gifts' ||
        selectedOccasions.isNotEmpty ||
        selectedCustomisations.isNotEmpty ||
        selectedBudgetIndex.value != 0;
    loadProducts();
  }

  void selectBudget(int index) {
    selectedBudgetIndex.value = index;
    hasActiveFilters.value =
        selectedCategory.value != 'All Gifts' ||
        selectedOccasions.isNotEmpty ||
        selectedCustomisations.isNotEmpty ||
        selectedBudgetIndex.value != 0;
    loadProducts();
  }

  void toggleOccasion(String occasion) {
    if (selectedOccasions.contains(occasion)) {
      selectedOccasions.remove(occasion);
    } else {
      selectedOccasions.add(occasion);
    }
    hasActiveFilters.value =
        selectedCategory.value != 'All Gifts' ||
        selectedOccasions.isNotEmpty ||
        selectedCustomisations.isNotEmpty ||
        selectedBudgetIndex.value != 0;
    loadProducts();
  }

  void toggleCustomisation(String value) {
    if (selectedCustomisations.contains(value)) {
      selectedCustomisations.remove(value);
    } else {
      selectedCustomisations.add(value);
    }
    hasActiveFilters.value =
        selectedCategory.value != 'All Gifts' ||
        selectedOccasions.isNotEmpty ||
        selectedCustomisations.isNotEmpty ||
        selectedBudgetIndex.value != 0;
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
    _searchDebounce?.cancel();
    isLastPage.value = false;
    products.clear();
    loadProducts();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
