import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:map_note/components/zoom_buttons.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:map_note/controller/auth_controller.dart';
import 'package:map_note/controller/map_data_controller.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapDataController mapDataController = Get.put(MapDataController());
  final AuthController authController = Get.put(AuthController());

  late final MapController mapController;
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));
  late final MapState map;
  final PopupController _popupLayerController = PopupController();

  @override
  void initState() {
    // TODO: implement initState
    mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(
          () => authController.userData.value.displayName != ''
              ? Text('${authController.userData.value.displayName}')
              : const Text('Map Note'),
        ),
        actions: [
          Obx(() {
            if (authController.isLogin.value) {
              return TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                child: const Icon(Icons.logout),
                onPressed: () {
                  authController.logout();
                },
              );
            } else {
              return const SizedBox();
            }
          })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('map_data')
            .where('uid', isEqualTo: authController.userData.value.uid)
            .snapshots(
              includeMetadataChanges: true,
            ),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Obx(
              () => FlutterMap(
                options: MapOptions(
                  center: mapDataController.selectCord.value,
                  minZoom: 2,
                  zoom: 2,
                  plugins: [ZoomButtonsPlugin()],
                  onTap: (tapPos, pos) {
                    mapDataController.selectCord(pos);
                    _popupLayerController.showPopupsOnlyFor(
                      [
                        Marker(
                          point: mapDataController.selectCord.value,
                          width: 40,
                          height: 40,
                          builder: (_) =>
                              const Icon(Icons.location_on, size: 40),
                          anchorPos: AnchorPos.align(AnchorAlign.top),
                        ),
                      ],
                      disableAnimation: true,
                    );
                  },
                ),
                mapController: mapController,
                nonRotatedLayers: [
                  ZoomButtonOption(alignment: Alignment.bottomRight),
                ],
                layers: [
                  MarkerLayerOptions(markers: [
                    ...snapshot.data!.docs.map(
                      (data) => Marker(
                        point: LatLng(
                          data['lat'],
                          data['lng'],
                        ),
                        builder: (context) => GestureDetector(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 12.0,
                              )
                            ],
                          ),
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                child: Container(
                                  width: 250,
                                  height: 210,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Cord show
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.blue,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            ' Lat : ${data['lat'].toStringAsFixed(2)}'),
                                                    TextSpan(
                                                        text:
                                                            ' / Lng : ${data['lng'].toStringAsFixed(2)}'),
                                                  ]),
                                            ),
                                          ],
                                        ),

                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //Title
                                                Text(
                                                  '${data['title']}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                //Desc
                                                Text(
                                                  '${data['desc']}',
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        //Actions
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            //Close
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                primary: Colors.red,
                                              ),
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Get.back();
                                              },
                                            ),
                                            //Delete note
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                if (authController
                                                        .userData.value.uid ==
                                                    data['uid']) {
                                                  mapDataController
                                                      .deleteMapData(data);
                                                }else{
                                                  Get.toNamed('/login');
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ])
                ],
                children: [
                  TileLayerWidget(
                    options: TileLayerOptions(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mg-kh/ckvqaj1y42snc14qkbw866cgk/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWcta2giLCJhIjoiY2t2bnNxNGd3MHVraDJycWZmMHhraDBreSJ9.KqI45Iw0Dvu98ZdoVufw6Q",
                      additionalOptions: {
                        "accessToken":
                            const String.fromEnvironment('MAP_BOX_TOKEN'),
                        "id": "mapbox.mapbox-streets-v8"
                      },
                    ),
                  ),
                  PopupMarkerLayerWidget(
                    options: PopupMarkerLayerOptions(
                        popupController: _popupLayerController,
                        markers: [
                          Marker(
                            point: mapDataController.selectCord.value,
                            width: 40,
                            height: 40,
                            builder: (_) =>
                                const Icon(Icons.location_on, size: 40),
                            anchorPos: AnchorPos.align(AnchorAlign.top),
                          ),
                        ],
                        markerRotateAlignment:
                            PopupMarkerLayerOptions.rotationAlignmentFor(
                                AnchorAlign.top),
                        popupBuilder: (BuildContext context, Marker marker) {
                          return Container(
                            width: 250,
                            height: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Cord show
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.blue,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      ' Lat : ${marker.point.latitude.toStringAsFixed(2)}'),
                                              TextSpan(
                                                  text:
                                                      ' / Lng : ${marker.point.longitude.toStringAsFixed(2)}'),
                                            ]),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  //Actions
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      //Close
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                        child: const Text('Close'),
                                        onPressed: () {
                                          _popupLayerController.hideAllPopups();
                                        },
                                      ),
                                      //Add note
                                      ElevatedButton(
                                        child: const Text('Add Note'),
                                        onPressed: () {
                                          if (authController.isLogin.value) {
                                            showBottomSheet(pos: marker.point);
                                          } else {
                                            Get.toNamed('/login');
                                          }
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void showBottomSheet({required pos}) {
    Get.bottomSheet(
      bottomSheetBuilder(pos: pos),
      backgroundColor: Colors.white,
    );
  }

  Widget bottomSheetBuilder({required pos}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Lat , Long
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.grey,
                ),
                RichText(
                  text: TextSpan(
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                            text: ' Lat : ${pos.latitude.toStringAsFixed(2)}'),
                        TextSpan(
                            text:
                                ' / Lng : ${pos.longitude.toStringAsFixed(2)}'),
                      ]),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            /// Title
            TextFormField(
              controller: mapDataController.title.value,
              decoration: const InputDecoration(hintText: 'Title'),
            ),

            const SizedBox(
              height: 20,
            ),

            /// Description
            TextFormField(
              controller: mapDataController.desc.value,
              decoration: const InputDecoration(hintText: 'Description'),
              maxLines: 4,
            ),

            const SizedBox(
              height: 20,
            ),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Get.back();
                  },
                ),
                ElevatedButton(
                  child: const Text('Add Note'),
                  onPressed: () {
                    mapDataController.addMapData(
                      data: {
                        'uid': authController.userData.value.uid,
                        'lat': pos.latitude,
                        'lng': pos.longitude,
                        'title': mapDataController.title.value.text,
                        'desc': mapDataController.desc.value.text,
                      },
                    ).then(
                      (value) => Get.back(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
