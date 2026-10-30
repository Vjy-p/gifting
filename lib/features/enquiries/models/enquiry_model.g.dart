// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enquiry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnquiryModelAdapter extends TypeAdapter<EnquiryModel> {
  @override
  final int typeId = 1;

  @override
  EnquiryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnquiryModel(
      id: fields[0] as String?,
      referenceCode: fields[1] as String?,
      name: fields[2] as String,
      company: fields[3] as String,
      phone: fields[4] as String,
      email: fields[5] as String,
      occasion: fields[6] as String,
      quantity: fields[7] as int,
      budget: fields[8] as String,
      deliveryDate: fields[9] as DateTime,
      products: (fields[10] as List).cast<ProductModel>(),
      customisations: (fields[11] as List).cast<String>(),
      message: fields[12] as String,
      source: fields[13] as String,
      status: fields[14] as String,
      createdAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EnquiryModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.referenceCode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.company)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.occasion)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.budget)
      ..writeByte(9)
      ..write(obj.deliveryDate)
      ..writeByte(10)
      ..write(obj.products)
      ..writeByte(11)
      ..write(obj.customisations)
      ..writeByte(12)
      ..write(obj.message)
      ..writeByte(13)
      ..write(obj.source)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnquiryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
