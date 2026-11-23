// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 2;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      category: fields[2] as String? ?? '',
      price: fields[3] as int? ?? 0,
      description: fields[5] as String? ?? '',
      imageUrl: fields[6] as String?,
      occasions: (fields[7] as List?)?.cast<String>() ?? const [],
      customisations: (fields[8] as List?)?.cast<String>() ?? const [],
      quantity: fields[9] as int? ?? 20,
      selectedOccasions: (fields[10] as List?)?.cast<String>() ?? const [],
      selectedCustomisations: (fields[11] as List?)?.cast<String>() ?? const [],
      message: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.occasions)
      ..writeByte(8)
      ..write(obj.customisations)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.selectedOccasions)
      ..writeByte(11)
      ..write(obj.selectedCustomisations)
      ..writeByte(12)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
