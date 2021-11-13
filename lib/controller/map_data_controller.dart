import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapDataController extends GetxController {
  static CollectionReference mapData =
      FirebaseFirestore.instance.collection('map_data');

  ///Default Values
  var selectCord = LatLng(21.9, 95.9).obs; //Head to myanmar
  var title = TextEditingController().obs;
  var desc = TextEditingController().obs;

  ///Add Map data to fire store
  Future<void> addMapData({required data}) {
    return mapData.add(data);
  }

  ///Edit Mapdata
  Future<void> editMapData() async {
    //
  }

  ///Delete Mapdata
  Future<void> deleteMapData(note) async {
    var docNote = mapData.doc(note.id);
    await docNote.delete();
    Get.back();
  }
}
