// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) => _LoginResponse(
  accessToken: json['accessToken'] as String,
  user: UserApiModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'user': instance.user.toJson(),
};
