import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapState();
}

class _MapState extends State<MapWidget> {
  late CameraPosition? _currentPosition = null;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() async {
    _getUserCurrentLocation().then((value) {
      print(value);
      setState(() {
        // _currentLatLng = LatLng(value.latitude, value.longitude);
        // _currentLatLng = LatLng(65.0610535, 25.4675335);
        // final _currentPosition = CameraPosition(
        //   target: LatLng(65.0610535, 25.4675335),
        //   zoom: 14,
        // );
        _currentPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );
      });
      _updateCamera(_currentPosition!);
    });
  }

  static const CameraPosition _kOamk = CameraPosition(
    target: LatLng(65.0610535, 25.4675335),
    zoom: 14.4746,
  );

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {
          print(value);
    })
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateCamera(CameraPosition pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(pos));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      compassEnabled: true,
      initialCameraPosition: _kOamk,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      // onCameraMove: null,
    );
  }
}
