import 'dart:async';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget{
  final double latitude;
  final double longetude;

  MapaPage({Key? key, required this.latitude, required this.longetude}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage>{
  final _controller = Completer<GoogleMapController>();
  StreamSubscription<Position>? _subscription;

  @override
  void initState(){
    super.initState();
    _monitorarLocalizacao();
  }

  @override
  void dispose(){
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Usando Mapa Interno'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(widget.latitude -1, widget.longetude -1), // o -1 da latitude e longetude tem que vim direto do banco de dados
            infoWindow: InfoWindow(title: 'Nome do ponto'),
          )
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longetude),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
        myLocationEnabled: true,
      ),
    );
  }

  void _monitorarLocalizacao(){
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position posicao) async{
      final controller = await _controller.future;
      final zoom = await controller.getZoomLevel();
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(posicao.latitude,posicao.longitude),
      zoom: zoom)
      )
      );
    });
  }

}