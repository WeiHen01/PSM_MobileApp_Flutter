/* import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../../Controller/Request Controller.dart';

import '../../../Model/Chat.dart';
import '../../../Model/Patient.dart';
import '../../../Controller/MongoDBController.dart';
import 'Social Chat Room.dart';

class SocialChat extends StatefulWidget {

  final int? id; 
  SocialChat({Key? key, this.id});

  @override
  State<SocialChat> createState() => _SocialChatState();
}

class _SocialChatState extends State<SocialChat> {

  TextEditingController searchCtrl = TextEditingController();

  
  late List<Patient> otherUsers = [];

  Future<void> getOtherPatients(int currentUserId) async {
    try {
      var patients = await MongoDatabase().getCertainInfo("Patient");
      print("All: $patients");

      if (patients.isNotEmpty) {
        setState(() {
          otherUsers = patients
              .map((json) => Patient.fromJson(json))
              .where((patient) => patient.patientid != currentUserId)
              .toList();
          
          // Call fetchProfileImages or any other processing if needed
          fetchProfileImages(otherUsers);
        });
      }
    } catch (e) {
      print('Error fetching other patients : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  

  String imageUrl = "images/Profile_2.png";
  late Uint8List? _images = Uint8List(0); // Default image URL
  late List<Uint8List?> profileImages = []; // List to store profile images

  Future<void> fetchProfileImages(List<Patient> patients) async {
    List<Uint8List?> images = [];
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    for (var patient in patients) {
      try {
        final response = await http.get(Uri.parse(
            'http://$server:8000/api/patient/profileImage/${patient.patientID}')
        );

        if (response.statusCode == 200) {
          images.add(response.bodyBytes);
        } else {
          images.add(Uint8List.fromList(utf8.encode("../../../../images/Profile_2.png")));
        }
      } catch (e) {
        print('Error fetching profile image for patient ${patient.patientID}: $e');
        images.add(Uint8List.fromList(utf8.encode("../../../../images/Profile_2.png")));
      }
    }
    setState(() {
      profileImages = images;
    });
  }

  late List<Map<String, dynamic>> lastMessages = []; // List to store the last message for each patient

  Future<List<Map<String, dynamic>>> getLastMessagesForPatients(List<Patient> patients) async {
    List<Map<String, dynamic>> messages = [];
    for (var patient in patients) {
      try {
        print("Patient: ${patient.patientID}");
        var chats = await MongoDatabase().getByQuery("Chat", {
          "\$or": [
            {"PatientID": "P-${patient.patientID}", "ReceiverID": "P-${widget.id}"},
            {"PatientID": "P-${widget.id}", "ReceiverID": "P-${patient.patientID}"}
          ]
        });

        // Sort chats by timestamp to get the latest message
        chats.sort((a, b) => b['ChatDateTime'].compareTo(a['ChatDateTime']));

        if (chats.isNotEmpty) {
          messages.add({
            'message': chats.first['ChatMessage'],
            'timestamp': chats.first['ChatDateTime']
          });
        } else {
          // If no chat found, add a default message
          messages.add({
            'message': '',
            'timestamp': ''
          });
        }
      } catch (e, stackTrace) {
        print('Error fetching last message for patient ${patient.patientID}: $e');
        print(stackTrace);
        // Handle the exception as needed
        messages.add({
          'message': '',
          'timestamp': ''
        });
      }
    }
    return messages;
  }

  Future<void> getLastMessagesForOtherPatients() async {
    try {
      var patients = await MongoDatabase().getCertainInfo("Patient");
      print("All: $patients");

      if (patients.isNotEmpty) {
        List<Patient> otherPatients = patients
            .map((json) => Patient.fromJson(json))
            .where((patient) => patient.patientID != widget.id)
            .toList();

        List<Map<String, dynamic>> messages = await getLastMessagesForPatients(otherPatients);

        setState(() {
          otherUsers = otherPatients;
          lastMessages = messages;
        });
      }
    } catch (e) {
      print('Error fetching other patients: $e');
      // Handle the exception as needed
    }
  }



  late Future<void> _fetchPatientsFuture;
  late Future<void> _fetchChatsFuture;
  


  

  String convertTo12HourFormat(String timestamp) {
    // Split the timestamp into date and time components
    List<String> components = timestamp.split(' ');

    // Extract date and time components
    String date = components[0];
    String time = components[1];

    // Split the time into hours, minutes, seconds, and milliseconds
    List<String> timeComponents = time.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    double second = double.parse(timeComponents[2]);

    // Determine the meridiem (AM or PM)
    String meridiem = hour < 12 ? 'AM' : 'PM';

    // Convert the hour to 12-hour format
    if (hour == 0) {
      hour = 12; // 12 AM
    } else if (hour > 12) {
      hour -= 12; // Convert to 12-hour format
    }

    // Format the time string
    String formattedTime = '$hour:${minute.toString().padLeft(2, '0')}:${second.toStringAsFixed(0).padLeft(2, '0')} $meridiem';
    
    // Return the formatted time
    return formattedTime;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ID: ${widget.id}");
    _fetchPatientsFuture = getOtherPatients(widget.id!);
    _fetchChatsFuture = getLastMessagesForOtherPatients();
  }

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


        title: Text("Chat", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),


      ),

      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
          _fetchPatientsFuture = getOtherPatients(widget.id!);
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                /* TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(),
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16.0
                  ),
                  
                ),
            
                const SizedBox(height: 10.0,), */

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GradientText(
                      'Other users',
                      style: GoogleFonts.poppins(
                          fontSize: 20.0, fontWeight: FontWeight.w600
                      ),
                      colors: [
                          Color(0xFF301847), Color(0xFFC10214)
                      ],
                  ),
                ),

                Container(
                  
                  height: 100,
                  child: FutureBuilder<void>(
                    future: Future.wait([_fetchPatientsFuture, _fetchChatsFuture, fetchProfileImages(otherUsers)]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.pink));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error fetching patients: ${snapshot.error}"));
                      } else {
                        return ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(width: 10),
                          scrollDirection: Axis.horizontal,
                          itemCount: otherUsers.length,
                          itemBuilder: (context, index) {
                            final patient = otherUsers[index];
                            final profileImage = profileImages[index];

                            return InkWell(
                              onTap: (){
                                Navigator.push(
                                  context, MaterialPageRoute(
                                    builder: (context) => SocialChatRoom(otherId: patient.patientID, selfId: widget.id)
                                  )
                                );
                              },
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  height: double.minPositive,
                                  padding: EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [

                                      CircleAvatar(
                                        backgroundImage: profileImage != null
                                          ? MemoryImage(profileImage ?? '')
                                          : AssetImage("../../../../images/Profile_2.png"),
                                        radius: 30,
                                      ),

                                      GradientText(patient.patientName, style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold, color: Colors.black,
                                        fontSize: 15.0
                                      ),
                                       colors: [
                                          Color(0xFF301847), Color(0xFFC10214)
                                      ],),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
            
                 


                SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GradientText(
                      'Chats',
                      style: GoogleFonts.poppins(
                          fontSize: 20.0, fontWeight: FontWeight.w600
                      ),
                      colors: [
                          Color(0xFF301847), Color(0xFFC10214)
                      ],
                    ),
                  ],
                ),

                Container(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: FutureBuilder<void>(
                    future: _fetchPatientsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.pink));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error fetching patients: ${snapshot.error}"));
                      } else {
                        return ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(height: 10),
                          itemCount: otherUsers.length,
                          itemBuilder: (context, index) {
                            final patient = otherUsers[index];
                            return InkWell(
                              onTap: (){
                                Navigator.push(
                                  context, MaterialPageRoute(
                                    builder: (context) => SocialChatRoom(otherId: patient.patientID, selfId: widget.id)
                                  )
                                );
                              },
                              child: Card(
                                elevation: 5,
                                child: ListTile(
                                  title: GradientText(patient.patientName, style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, color: Colors.black,
                                    fontSize: 18.0
                                  ),
                                  colors: [
                                      Color(0xFF301847), Color(0xFFC10214)
                                  ],),
                                                        
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
            
                
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}


                            
                         */