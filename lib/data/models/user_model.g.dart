// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      photoUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      lastLoginAt: fields[5] as DateTime?,
      isEmailVerified: fields[6] as bool,
      preferences: (fields[7] as Map?)?.cast<String, dynamic>(),
      firstName: fields[8] as String?,
      lastName: fields[9] as String?,
      gender: fields[10] as String?,
      age: fields[11] as int?,
      location: fields[12] as String?,
      currentStreak: fields[13] as int,
      longestStreak: fields[14] as int,
      lastActiveDate: fields[15] as DateTime?,
      updatedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastLoginAt)
      ..writeByte(6)
      ..write(obj.isEmailVerified)
      ..writeByte(7)
      ..write(obj.preferences)
      ..writeByte(8)
      ..write(obj.firstName)
      ..writeByte(9)
      ..write(obj.lastName)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.age)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.currentStreak)
      ..writeByte(14)
      ..write(obj.longestStreak)
      ..writeByte(15)
      ..write(obj.lastActiveDate)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
