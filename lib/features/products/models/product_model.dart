import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.imageUrl,
    this.occasions = const [],
    this.customisations = const [],
    this.quantity = 20,
    this.selectedOccasions = const [],
    this.selectedCustomisations = const [],
    this.message,
  });

  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String name;

  @HiveField(2, defaultValue: '')
  final String category;

  @HiveField(3, defaultValue: 0)
  final int price;

  @HiveField(5, defaultValue: '')
  final String description;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7, defaultValue: <String>[])
  final List<String> occasions;

  @HiveField(8, defaultValue: <String>[])
  final List<String> customisations;

  @HiveField(9, defaultValue: 20)
  int quantity;

  @HiveField(10, defaultValue: <String>[])
  List<String> selectedOccasions;

  @HiveField(11, defaultValue: <String>[])
  List<String> selectedCustomisations;

  @HiveField(12)
  final String? message;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      occasions: List<String>.from(json['occasions'] ?? const []),
      customisations: List<String>.from(json['customisations'] ?? const []),
      message: json['message']?.toString() ?? '',
      quantity: json['quantity'] ?? 20,
      selectedOccasions: List<String>.from(
        json['selectedOccasions'] ?? const [],
      ),
      selectedCustomisations: List<String>.from(
        json['selectedCustomisations'] ?? const [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'occasions': occasions,
      'customisations': customisations,
      'message': message,
      'quantity': quantity,
      'selectedCustomisations': selectedCustomisations,
      'selectedOccasions': selectedOccasions,
    };
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
