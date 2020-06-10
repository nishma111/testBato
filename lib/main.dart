import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Bato',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Test Bato'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Change Here
  final String user = 'first';
  GoogleMapController mapController;
  List<Marker> markers = [];
  int index = 0;

  @override
  void initState() {
    _pullData();
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(0, 0), zoom: 15.0),
      ),
    );
  }

  void _pullData() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("locations").getDocuments();
    querySnapshot.documents.forEach((doc) {
      markers.add(Marker(
          markerId: MarkerId(doc.documentID),
          position:
              LatLng(doc['latitude'].toDouble(), doc['longitude'].toDouble()),
          infoWindow: InfoWindow(title: doc.documentID)));
    });
  }

  void _changeLatLng() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // current position latitude and longitude
    Map<String, double> pos = {
      'latitude': position.latitude,
      'longitude': position.longitude
    };

    // Update values of latitude and longitude in firebase
    Firestore.instance.collection('locations').document(user).updateData(pos);

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 15.0,
            ),
            markers: markers.toSet()),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FloatingActionButton(
                    backgroundColor: Color(0xff212f3d),
                    child: Icon(Icons.add),
                    onPressed: _changeLatLng,
                  ),
                  Expanded(child: Container()),
                  FloatingActionButton(
                    backgroundColor: Color(0xff212f3d),
                    child: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      print(index);
                      index = (index - 1) % markers.length;
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: markers[index].position, zoom: 15.0),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  FloatingActionButton(
                    backgroundColor: Color(0xff212f3d),
                    child: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      print(index);
                      index = (index + 1) % markers.length;
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: markers[index].position, zoom: 15.0),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        )
      ]),
    );
  }
}
