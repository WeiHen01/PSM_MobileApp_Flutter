import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyLocation extends StatefulWidget {
  const EmergencyLocation({super.key});

  @override
  State<EmergencyLocation> createState() => _EmergencyLocationState();
}

class _EmergencyLocationState extends State<EmergencyLocation> {

  String? latitude, longitude, address; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),

        title: Text("Location", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Longitude: $longitude"),
              Text("Latitude: $latitude"),
              Text("Address: $address"),

              ElevatedButton(
                onPressed: ()async{
                  try {
                    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    setState(() {
                      latitude = position.latitude.toString();
                      longitude = position.longitude.toString();
                    });
                    final coordinates = Coordinates(position.latitude, position.longitude);
                    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                    final _address = addresses.first.addressLine;
                    setState(() {
                      address = _address;
                    });
                  } catch (e) {
                    print("Error: $e");
                  }
                }, 
                child: Text("Get Location")
              )
            ],
          ),
        ),
      ),
    );
  }
}