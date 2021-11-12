import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:map_note/components/zoom_buttons.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:map_note/controller/app_controller.dart';
import 'package:map_note/screens/login.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AppController appController = Get.put(AppController());

  late final MapController mapController;
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));
  late final MapState map;
  final PopupController _popupLayerController = PopupController();
  var selectCord = LatLng(21.9, 95.9).obs;
  var title = TextEditingController();
  var desc = TextEditingController();

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
          () => appController.userData.value.isNotEmpty
          ? Text('${appController.userData['displayName']}')
          : const Text('Map Note'),
        ),
        actions: [
          Obx((){
            if(appController.isLogin.value){
              return TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                child: const Icon(Icons.logout),
                onPressed: () {
                  appController.logout();
                },
              );
            }else{
              return const SizedBox();
            }
          })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('map_data').where('uid', isEqualTo: appController.userData['uid']).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Obx(
              () => FlutterMap(
                options: MapOptions(
                  center: selectCord.value,
                  minZoom: 2,
                  zoom: 2,
                  plugins: [ZoomButtonsPlugin()],
                  onTap: (tapPos, pos) {
                    selectCord(pos);
                    _popupLayerController.showPopupsOnlyFor(
                      [
                        Marker(
                          point: selectCord.value,
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
                                            //Edit note
                                            ElevatedButton(
                                              child: const Text('Edit Note'),
                                              onPressed: () {
                                                // showBottomSheet(pos: marker.point);
                                              },
                                            )
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
                            point: selectCord.value,
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
                                          if (appController.isLogin.value) {
                                            showBottomSheet(pos: marker.point);
                                          } else {
                                            Get.to(() => Login());
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
            // Lat , Long
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

            // Choose Icons
            OutlinedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Choose Icon'),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.sentiment_satisfied_alt),
                ],
              ),
              onPressed: () {},
            ),

            // Title
            TextFormField(
              controller: title,
              decoration: const InputDecoration(hintText: 'Title'),
            ),

            const SizedBox(
              height: 20,
            ),

            // Description
            TextFormField(
              controller: desc,
              decoration: const InputDecoration(hintText: 'Description'),
              maxLines: 4,
            ),

            const SizedBox(
              height: 20,
            ),

            // Actions
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
                    appController.addMapData(
                      data: {
                        'uid': appController.userData['uid'],
                        'lat': pos.latitude,
                        'lng': pos.longitude,
                        'title': title.text,
                        'desc': desc.text,
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
