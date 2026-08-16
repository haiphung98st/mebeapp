import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarConfig {
  const AvatarConfig({
    this.headColor = const Color(0xFFFFF0F6),
    this.earColor = const Color(0xFFFFB7CE),
    this.eyeColor = const Color(0xFF3D1A35),
    this.noseColor = const Color(0xFFF472A0),
    this.cheekColor = const Color(0xFFFFB7CE),
  });

  final Color headColor;
  final Color earColor;
  final Color eyeColor;
  final Color noseColor;
  final Color cheekColor;

  AvatarConfig copyWith({
    Color? headColor,
    Color? earColor,
    Color? eyeColor,
    Color? noseColor,
    Color? cheekColor,
  }) {
    return AvatarConfig(
      headColor: headColor ?? this.headColor,
      earColor: earColor ?? this.earColor,
      eyeColor: eyeColor ?? this.eyeColor,
      noseColor: noseColor ?? this.noseColor,
      cheekColor: cheekColor ?? this.cheekColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'headColor': headColor.value,
    'earColor': earColor.value,
    'eyeColor': eyeColor.value,
    'noseColor': noseColor.value,
    'cheekColor': cheekColor.value,
  };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
    headColor: Color(json['headColor'] as int),
    earColor: Color(json['earColor'] as int),
    eyeColor: Color(json['eyeColor'] as int),
    noseColor: Color(json['noseColor'] as int),
    cheekColor: Color(json['cheekColor'] as int),
  );

  String toJsonString() => jsonEncode(toJson());

  factory AvatarConfig.fromJsonString(String s) =>
      AvatarConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
