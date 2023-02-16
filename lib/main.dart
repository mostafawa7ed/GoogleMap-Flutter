import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  //start
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyAEEvzWfqTkRlpj5oYsavZxaAm0btd-uho";
  //end
   var cl,cl2;
   var _kGooglePlex  ;
   var lat,lng;
   StreamSubscription<Position>? positionStream;
            Future getpermission() async {
              bool services;
              LocationPermission Lper;
              services = await Geolocator.isLocationServiceEnabled(); //to check the service location is worked
              if (services != true)
                {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Services located not worked',
                    desc: 'Go start it',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  )..show();
                }
              Lper = await Geolocator.checkPermission();
              print(Lper);
              if (Lper == LocationPermission.denied )
                {
                  Lper = await Geolocator.requestPermission();
                 if(Lper ==LocationPermission.whileInUse)
                   {

                   }
                }
            }  //to getpermission and check it
  Future<void> getlatandlong() async  // to get lagitude and longitude
  {
    print("test 2");
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl.latitude;
    lng = cl.longitude;
    _kGooglePlex = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 2.151926040649414);
    mymarker.add(Marker(markerId: MarkerId("22"),position: LatLng(lat, lng) ));
    setState(() {
       //to make refesh
    });
  }
  changeMarker(newlat, newlng)
  {
    mymarker.remove(Marker(markerId: MarkerId("22")));
    mymarker.add(Marker(markerId: MarkerId("22"),position: LatLng(newlat, newlng) ));
    gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(newlat,newlng)));
  }
  @override
  void initState() {
    positionStream = Geolocator.getPositionStream().listen(
            (Position? position) {
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
          changeMarker(position!.latitude,position.longitude);
        });

    getpermission();
    getlatandlong();
    setMarakerCutomImage();
    getPolyline();
    print(_kGooglePlex);
    super.initState();
  }
  GoogleMapController? gmc;
            double zoom = 1.0;
   Completer<GoogleMapController> _controller = Completer();
   setMarakerCutomImage() async{
     mymarker.add(Marker(icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'images/3.png'),
       draggable: true,onDragEnd: (LatLng t){
         print(t);
       },infoWindow: InfoWindow(title: "first",onTap: (){
         print("1");
       }),
       markerId: MarkerId("1"),position:LatLng(24.342092, 39.627329), ));
   }
    Set<Marker> mymarker = {
      //Marker(markerId: MarkerId("2"),position:LatLng(25.342092, 39.627329), ),
      //Marker(markerId: MarkerId("3"),position:LatLng(26.342092, 39.627329), )
    };
   static final CameraPosition _kLake = CameraPosition(
       bearing: 192.8334901395799,
       target: LatLng(37.43296265331129, -122.08832357078792),
       tilt: 59.440717697143555,
       zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
      appBar: AppBar(),
      body:
      _kGooglePlex == null ? Center(child: CircularProgressIndicator()) :
      Center(
        child: Column(
          children: [
            MaterialButton(onPressed: () async {
              //double distanceInMeters =await Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
              //print(distanceInMeters);
                    print(cl);
            },child: Text("show lat and long "),),
            Container(
              height: 500,width: double.infinity,
              child: GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                onTap:  (LatLng p)  async {
                  setState(() {

                  });
                  mymarker.remove(Marker(markerId: MarkerId("1")));
                  mymarker.add(Marker(icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'images/3.png'),
                    draggable: true,onDragEnd: (LatLng t){
                      print(t);
                    },infoWindow: InfoWindow(title: "first",onTap: (){
                      print("1");
                    }),
                    markerId: MarkerId("1"),position:LatLng(p.latitude, p.longitude), ));
                },
                markers: mymarker,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  //_controller.complete(controller);
                  gmc = controller;
                },
              ),
            ),
            ElevatedButton(onPressed: () async {
               zoom =  await gmc!.getZoomLevel()+1.0;
              LatLng lattlang = new LatLng(24.342092, 39.627329);
              //can add camera poision
              gmc!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: lattlang,zoom: zoom)));
              //gmc.moveCamera(cameraUpdate)
             // gmc.getLatLng(screenCoordinate)
            }, child: Text("go to")),

          ],
        ),
      ),
    );
  }
   Future<void> _goToTheLake() async {
     final GoogleMapController controller = await _controller.future;
     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
   }
  addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  getPolyline() async {
    var polylinePoints;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(33.647779, 36.295052),
        PointLatLng(35.324235, 40.234235),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(33.647779, 36.295052));
        polylineCoordinates.add(LatLng(35.324235, 40.234235));
      //});
    addPolyLine();
    }

  }


//21.289374
