import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive/hive.dart';

part 'enquiry_model.g.dart';

@HiveType(typeId: 1)
class EnquiryModel {
  const EnquiryModel({
    this.id,
    this.referenceCode,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.occasion,
    required this.quantity,
    required this.budget,
    required this.deliveryDate,
    required this.products,
    required this.customisations,
    required this.message,
    required this.source,
    this.status = 'New',
    this.createdAt,
  });

  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? referenceCode;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String company;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String email;

  @HiveField(6)
  final String occasion;

  @HiveField(7)
  final int quantity;

  @HiveField(8)
  final String budget;

  @HiveField(9)
  final DateTime deliveryDate;

  @HiveField(10)
  final List<ProductModel> products;

  @HiveField(11)
  final List<String> customisations;

  @HiveField(12)
  final String message;

  @HiveField(13)
  final String source;

  @HiveField(14)
  final String status;

  @HiveField(15)
  final DateTime? createdAt;

  EnquiryModel copyWith({
    String? id,
    String? referenceCode,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? occasion,
    int? quantity,
    String? budget,
    DateTime? deliveryDate,
    List<ProductModel>? products,
    List<String>? customisations,
    String? message,
    String? source,
    String? status,
    DateTime? createdAt,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      referenceCode: referenceCode ?? this.referenceCode,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      occasion: occasion ?? this.occasion,
      quantity: quantity ?? this.quantity,
      budget: budget ?? this.budget,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      products: products ?? this.products,
      customisations: customisations ?? this.customisations,
      message: message ?? this.message,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Data sent when inserting a new enquiry.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'occasion': occasion,
      'quantity': quantity,
      'budget': budget,
      'delivery_date': _dateOnly(deliveryDate),
      'products': products.map((product) => product.toJson()).toList(),
      'customisations': customisations,
      'message': message,
      'source': source,
      'status': status,
    };
  }

  /// Data received when reading an enquiry from Supabase.
  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List? ?? [];

    return EnquiryModel(
      id: json['id']?.toString(),
      referenceCode: json['reference_code']?.toString(),
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      occasion: json['occasion']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      budget: json['budget']?.toString() ?? '',
      deliveryDate: DateTime.parse(json['delivery_date'].toString()),
      products: rawProducts.map((item) {
        if (item is Map) {
          return ProductModel.fromJson(Map<String, dynamic>.from(item));
        }

        // Supports older enquiries where products were stored as names.
        return ProductModel(
          id: '',
          name: item.toString(),
          category: '',
          minPrice: 0,
          maxPrice: 0,
          description: '',
        );
      }).toList(),
      customisations: List<String>.from(json['customisations'] ?? const []),
      message: json['message']?.toString() ?? '',
      source: json['source']?.toString() ?? 'website',
      status: json['status']?.toString() ?? 'New',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  static String _dateOnly(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    return '${localDate.year.toString().padLeft(4, '0')}-'
        '${localDate.month.toString().padLeft(2, '0')}-'
        '${localDate.day.toString().padLeft(2, '0')}';
  }
}
