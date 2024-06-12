import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:local_ip_plugin/local_ip_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:network_info_plus/network_info_plus.dart';



import '../../../Controller/Request Controller.dart';
import '../../../Controller/MongoDBController.dart';
import '../Home.dart';
import 'About Me.dart';
import 'Change Password.dart';
import 'Edit Profile.dart';

class PatientProfile extends StatefulWidget {
  
  final int? id;

  PatientProfile({Key? key, this.id});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {

  String name = "", email = "";
  
  Future<void> getProfile () async {
    MongoDatabase mongo = MongoDatabase();
    mongo.open("Patient");
    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientID'] == widget.id) {
        setState((){
          patientData = user;
          name = patientData["PatientName"];
          email = patientData["PatientEmail"];
        });
        break;
      }
    }
   
  }
  
  /* String name = "", email = "";

  Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      path: "patient/findPatient/${widget.id}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["PatientName"];
          email = data["PatientEmail"];
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  Future<String?> getWifiIpAddress() async {
    final networkInfo = NetworkInfo();
    final wifiInfo = await networkInfo.getWifiIP();
    final wifibroad = await networkInfo.getWifiBroadcast();
    print("IP: $wifiInfo, Broadcast: $wifibroad");
    return wifiInfo;
  }

  String imageUrl = "images/Profile_2.png";
  late Uint8List? _images = Uint8List(0); // Default image URL

  // Default image URL
  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8000/api/patient/profileImage/${widget.id}')
    );

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWifiIpAddress();
    MongoDatabase db = MongoDatabase();
    db.open("Patient");
    getProfile();
    fetchProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Your Profile", style: GoogleFonts.poppins(
            fontSize: 20.0, color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                  )
              ),
            ),
        
            RefreshIndicator(
              edgeOffset: 50,
              displacement: 120,
              color: Colors.orange,
              onRefresh: ()async {
                // Simulate a time-consuming task
                await Future.delayed(Duration(seconds: 1));
                getProfile();
                fetchProfileImage();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Column(
                        
                    children: [
                
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          Card(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                                )
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4.0,
                                            ),
                                            image: _images != null
                                                ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: MemoryImage(_images!)
                                            )
                                                : DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(imageUrl)
                                            )
                                          ), 
                                            
                                        ),
                                                  
                                          
                                                  
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                
                                  GradientText(
                                      name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 25.0, fontWeight: FontWeight.bold
                                      ),
                                      colors: [
                                          Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                  ),
                                                
                                  Text(email, style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                    )
                                  ),
                                                
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                                
                                 /*  Row(
                                    children: [
                                      Text("Description", style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                        )
                                      ),
                                    ],
                                  ), */
                
                                  const SizedBox(height: 20.0),
                                            
                                                
                                  InkWell(
                                    onTap: ()=>Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context)=>PatientEditProfile(id: widget.id ?? 0)
                                      )
                                    ),
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)
                                          ),
                                                
                                          border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF301847), Color(0xFFC10214)
                                              ]
                                            ),
                                            width: 4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit),
                
                                            const SizedBox(width: 5.0),
                
                                            Text("Edit This Profile", style: GoogleFonts.poppins(
                                                fontSize: 16.0, color: Colors.black,
                                                fontWeight: FontWeight.bold
                                              )
                                            ),
                                          ],
                                        )
                                      ),
                                    )
                                  ),
                                                
                                  
                                                
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                
                      const SizedBox(height: 20.0),
                
                      /* Card(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            ),
                            color: Colors.white
                          ),
                          child: InkWell(
                            onTap: ()=>Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context)=>UserAboutMe()
                              )
                            ),
                            child: Row(
                              children: [
                        
                                const Icon(Icons.person), 
                        
                                const SizedBox(width: 10),
                        
                                Text("About Me", style: GoogleFonts.poppins(
                                    fontSize: 18.0
                                  )
                                ),
                            
                                const Spacer(),
                            
                                const Icon(Icons.arrow_forward_ios_outlined)
                                
                              ],
                            ),
                          ),
                        ),
                      ), */
                        
                      const SizedBox(height: 10.0),
                        
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            ),
                            color: Colors.white
                          ),
                          child: InkWell(
                            onTap: ()=>Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context)=>UserChangePassword(id: widget.id ?? 0)
                              )
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock),
                        
                                const SizedBox(width: 10),
                        
                                Text("Change Password", style: GoogleFonts.poppins(
                                    fontSize: 18.0
                                  )
                                ),
                            
                                const Spacer(),
                            
                                const Icon(Icons.arrow_forward_ios_outlined)
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                
                      const SizedBox(height: 30.0),
                
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            ),
                            color: Color(0xFFFF1100)
                          ),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete, color: Colors.white,),
                        
                                const SizedBox(width: 10),
                        
                                Text("Delete this account", style: GoogleFonts.poppins(
                                    fontSize: 18.0, color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                            
                            
                              ],
                            ),
                          ),
                        ),
                      ),
                        

                      SizedBox(height: 30),
                        
                        
                        
                    ],
                  ),
                ),
              ),
            ),
        
        
        
          ],
        ),
      )
    );
  }
}