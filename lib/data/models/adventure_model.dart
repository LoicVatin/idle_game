import 'dart:math';

import 'package:flutter/material.dart';

class Adventure {
  final String name;
  final String workerName;
  final IconData workerIcon;
  final IconData workerTool;

  //
  final String encounterOneName;
  final IconData encounterOneIcon;
  final Color encounterOneColor;

  //
  final String encounterTwoName;
  final IconData encounterTwoIcon;
  final Color encounterTwoColor;

  //
  final String restName;
  final IconData restIcon;
  final Color restColor;

  Adventure({
    required this.name,
    required this.workerName,
    required this.workerIcon,
    required this.workerTool,
    //
    required this.encounterOneName,
    required this.encounterOneIcon,
    required this.encounterOneColor,
    //
    required this.encounterTwoName,
    required this.encounterTwoIcon,
    required this.encounterTwoColor,
    //
    required this.restName,
    required this.restIcon,
    required this.restColor,
  });

  static Adventure randomAdventure() {
    return [
      Adventure(
        name: "Adventure",
        workerName: "Adventurer",
        workerIcon: Icons.hiking_outlined,
        workerTool: Icons.colorize_sharp,
        //
        encounterOneName: "Marsh",
        encounterOneIcon: Icons.grass_outlined,
        encounterOneColor: Colors.lime.shade600,
        //
        encounterTwoName: "Swamp",
        encounterTwoIcon: Icons.panorama_outlined,
        encounterTwoColor: Colors.lime.shade900,
        //
        restName: "Abode",
        restIcon: Icons.houseboat_outlined,
        restColor: Colors.lime,
      ),
      Adventure(
        name: "Expedition",
        workerName: "Explorer",
        workerIcon: Icons.blind_outlined,
        workerTool: Icons.carpenter_sharp,
        //
        encounterOneName: "Deserted Village",
        encounterOneIcon: Icons.cottage_outlined,
        encounterOneColor: Colors.brown.shade200,
        //
        encounterTwoName: "Ruins",
        encounterTwoIcon: Icons.villa_outlined,
        encounterTwoColor: Colors.lime.shade900,
        //
        restName: "Shelter",
        restIcon: Icons.gite_outlined,
        restColor: Colors.brown.shade600,
      ),
      Adventure(
        name: "Mission",
        workerName: "Traveler",
        workerIcon: Icons.nordic_walking_outlined,
        workerTool: Icons.gavel_sharp,
        //
        encounterOneName: "Cave",
        encounterOneIcon: Icons.landscape_outlined,
        encounterOneColor: Colors.grey.shade700,
        //
        encounterTwoName: "Deep Mine",
        encounterTwoIcon: Icons.subway_outlined,
        encounterTwoColor: Colors.blueGrey.shade900,
        //
        restName: "Mineshaft",
        restIcon: Icons.shopping_cart_outlined,
        restColor: Colors.brown.shade400,
      ),
      Adventure(
        name: "Trial",
        workerName: "Fighter",
        workerIcon: Icons.directions_run_outlined,
        workerTool: Icons.waving_hand_sharp,
        //
        encounterOneName: "Grassland",
        encounterOneIcon: Icons.grass_outlined,
        encounterOneColor: Colors.lightGreen.shade600,
        //
        encounterTwoName: "Savanna",
        encounterTwoIcon: Icons.volcano_outlined,
        encounterTwoColor: Colors.orangeAccent.shade200,
        //
        restName: "Hut",
        restIcon: Icons.bungalow_outlined,
        restColor: Colors.brown,
      ),
      Adventure(
        name: "Escapade",
        workerName: "Wanderer",
        workerIcon: Icons.snowshoeing_outlined,
        workerTool: Icons.ice_skating_sharp,
        //
        encounterOneName: "Tundra",
        encounterOneIcon: Icons.waves_outlined,
        encounterOneColor: Colors.deepOrangeAccent.shade200,
        //
        encounterTwoName: "Sea Ice",
        encounterTwoIcon: Icons.tsunami_outlined,
        encounterTwoColor: Colors.blue.shade100,
        //
        restName: "Igloo",
        restIcon: Icons.stadium_outlined,
        restColor: Colors.lightBlueAccent.shade100,
      ),
    ].randomItem();
  }
}

extension RandomListItem<T> on List<T> {
  T randomItem() {
    return this[Random().nextInt(length)];
  }
}
