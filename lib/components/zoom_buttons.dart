import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/map.dart';
import 'package:flutter/material.dart';

class ZoomButtonOption extends LayerOptions {
  late final Alignment alignment;
  late final int minZoom;
  late final int maxZoom;

  ZoomButtonOption({
    required this.alignment,
    this.minZoom = 3,
    this.maxZoom = 18,
  });
}

class ZoomButtonsPlugin extends MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    if (options is ZoomButtonOption) {
      return ZoomButton(
        zoomButtonOption: options,
        map: mapState,
        stream: stream,
      );
    }
    throw UnimplementedError();
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ZoomButtonOption;
  }
}

class ZoomButton extends StatelessWidget {
  late ZoomButtonOption zoomButtonOption;
  late MapState map;
  late Stream<void> stream;
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(0));

  ZoomButton({
    Key? key,
    required this.zoomButtonOption,
    required this.map,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          right: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // reset zoom
            FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.refresh),
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                map.move(
                  centerZoom.center,
                  1,
                  source: MapEventSource.custom,
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),

            //!Zoom in
            FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.add),
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                if (int.parse(centerZoom.zoom.toStringAsFixed(0)) <
                    int.parse(zoomButtonOption.maxZoom.toStringAsFixed(0))) {
                  var zoom = centerZoom.zoom + 1;
                  map.move(
                    centerZoom.center,
                    zoom,
                    source: MapEventSource.custom,
                  );
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),

            //Zoom out
            FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.remove),
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                if (int.parse(centerZoom.zoom.toStringAsFixed(0)) >=
                    int.parse(zoomButtonOption.minZoom.toStringAsFixed(0))) {
                  var zoom = centerZoom.zoom - 1;
                  map.move(
                    centerZoom.center,
                    zoom,
                    source: MapEventSource.custom,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
