import 'package:flutter/cupertino.dart';

class WorkerModel {
  final double damage;
  final IconData icon;
  final IconData toolsIcon;

  WorkerModel({this.damage = 1, required this.icon, required this.toolsIcon});

  WorkerModel copyWith({double? damage, IconData? icon, IconData? toolsIcon}) {
    return WorkerModel(
      damage: damage ?? this.damage,
      icon: icon ?? this.icon,
      toolsIcon: toolsIcon ?? this.toolsIcon,
    );
  }
}
