import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.description,
    this.imageUrl,
    this.occasions = const [],
    this.customisations = const [],
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int minPrice;

  @HiveField(4)
  final int maxPrice;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final List<String> occasions;

  @HiveField(8)
  final List<String> customisations;

  String get priceRange =>
      '₹${_formatPrice(minPrice)}–₹${_formatPrice(maxPrice)}';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      minPrice: (json['min_price'] as num?)?.toInt() ?? 0,
      maxPrice: (json['max_price'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      occasions: List<String>.from(json['occasions'] ?? const []),
      customisations: List<String>.from(json['customisations'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'min_price': minPrice,
      'max_price': maxPrice,
      'description': description,
      'image_url': imageUrl,
      'occasions': occasions,
      'customisations': customisations,
    };
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
