import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  CameraPosition positionFirst = CameraPosition(target: LatLng(48.858370,2.294481),zoom: 1.0);
  Completer<GoogleMapController> controller = Completer();
  Position? maPosition;
  CameraPosition? positionActuelle;


  Future<Position> verificationAuthorisation() async {
    bool serviceEnabled;
    LocationPermission locationPermission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error("La localisation n'est pas disponible");
    }
    locationPermission = await Geolocator.checkPermission();
    if(locationPermission == LocationPermission.denied){
      locationPermission = await Geolocator.requestPermission();
      if(locationPermission == LocationPermission.denied){
        return Future.error("La permission est refusé");
      }
    }
    if(locationPermission ==  LocationPermission.deniedForever){
      return Future.error("La permission sera toujours refusé");
    }
    return await Geolocator.getCurrentPosition();

  }

  @override
  void initState() {
    // TODO: implement initState
    verificationAuthorisation().then((Position pos){
      setState(() {
        maPosition = pos;
        positionActuelle = CameraPosition(target: LatLng(maPosition!.latitude,maPosition!.longitude),zoom: 14);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(

      body: bodyPage()

    );
  }
  
  Widget myWidgetContainer(){
    return Column(
      children: [
        SizedBox(height: 40,),
        Container(
          padding: EdgeInsets.all(10),
        height: 100,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //premier élemént
              Row(
                children: [
                  Icon(Icons.pin_drop,size: 50,),
                  Text("Latitude : ${maPosition!.latitude}, Longitude : ${maPosition!.longitude}")
                ],
              ),

              //Deuxième élement

            ],
          ),
        ),
      ],
    );
  }


  Widget bodyPage(){
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: positionActuelle!,
          onMapCreated: (GoogleMapController control) async{
            String styleMap = await DefaultAssetBundle.of(context).loadString("lib/style/mapstyle.json");
            control.setMapStyle(styleMap);

            controller.complete(control);

          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,

        ),
        
        //Container de position
        Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: myWidgetContainer(),
        ),
        
      ],
    );
  }
}
