import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:collection/collection.dart';

import '../../../Controller/Request Controller.dart';
import '../../../Model/Chat.dart';
import '../../../Model/Doctor.dart';
import '../../../Controller/MongoDBController.dart';
import 'Chatroom Doctor.dart';

class ChatWithDoctor extends StatefulWidget {
  
  final int? id; 
  ChatWithDoctor({Key? key, this.id});

  @override
  State<ChatWithDoctor> createState() => _ChatWithDoctorState();
}

class _ChatWithDoctorState extends State<ChatWithDoctor> {

  late List<Doctor> doctors = [];
  Future<void> getAllDoctors() async {
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var doctor = await MongoDatabase().getCertainInfo("Doctor");
      print("All: $doctor");
      
      if(doctor.isNotEmpty){
        setState((){
          doctors = doctor.map((json) => Doctor.fromJson(json)).toList();

          fetchProfileImages(doctors);
        });
      }

    } catch (e) {
      print('Error fetching other doctors : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

  late List<Map<String, dynamic>> lastMessages = []; // List to store the last message for each doctor

  Future<List<Map<String, dynamic>>> getLastMessagesForDoctors(List<Doctor> doctors) async {
    List<Map<String, dynamic>> messages = [];
    for (var doctor in doctors) {
      try {
        print("Doctor: ${doctor.doctorID}");
        var chats = await MongoDatabase().getByQuery("Chat", {
          "\$or": [
            {"PatientID": "P-${widget.id}", "ReceiverID": "D-${doctor.doctorID}"},
            {"PatientID": "D-${doctor.doctorID}", "ReceiverID": "P-${widget.id}"}
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
      } catch (e) {
        print('Error fetching last message for doctor ${doctor.doctorID}: $e');
        // Handle the exception as needed
        messages.add({
          'message': 'Error fetching message',
          'timestamp': ''
        });
      }
    }
    return messages;
  }

  Future<void> getAllDoctorsWithLastMessages() async {
    try {
      var doctors = await MongoDatabase().getCertainInfo("Doctor");
      print("All Doctors: $doctors");

      if (doctors.isNotEmpty) {
        List<Doctor> fetchedDoctors = doctors.map((json) => Doctor.fromJson(json)).toList();
        List<Map<String, dynamic>> messages = await getLastMessagesForDoctors(fetchedDoctors);

        print("Last :$messages");

        setState(() {
          doctors = fetchedDoctors;
          lastMessages = messages;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching doctors: $e');
      print(stackTrace);
      // Handle the exception as needed
    }
  }

  String imageUrl = "images/Profile_2.png";
  late List<Uint8List?> profileImages = []; // List to store profile images

  Future<void> fetchProfileImages(List<Doctor> doctors) async {
    List<Uint8List?> images = [];
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    for (var doctor in doctors) {
      try {
        final response = await http.get(Uri.parse(
            'http://$server:8000/api/doctor/profileImage/${doctor.doctorID}')
        );

        if (response.statusCode == 200) {
          images.add(response.bodyBytes);
        } else {
          images.add(Uint8List.fromList(utf8.encode(imageUrl)));
        }
      } catch (e) {
        print('Error fetching profile image for doctor ${doctor.doctorID}: $e');
        images.add(Uint8List.fromList(utf8.encode(imageUrl)));
      }
    }
    setState(() {
      profileImages = images;
    });
  }

  
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

  /* Future<void> getAllDoctors () async {
    WebRequestController req = WebRequestController(
      path: "doctor"
    );

    await req.get();

    try{
      if (req.status() == 200) {
        List<dynamic> data = req.result();

        setState(() {
          doctors = data.map((json) => Doctor.fromJson(json)).toList();
        });
        
      }
    }catch (e) {
      print('Error fetching doctors : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  

  

  /* Future<void> getChatsBubbles (int otherId) async {
    WebRequestController req = WebRequestController(
      path: "chat/findChatBetween/P-${widget.id}/D-${otherId}"
    );

    await req.get();

    try{
      if (req.status() == 200) {
        List<dynamic> data = req.result();

        setState(() {
          wifdoctorChats = data.map((json) => Chat.fromJson(json)).toList();
        });
        
      }
    }catch (e) {
      print('Error fetching abc : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  late Future<void> getDoctors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ID: ${widget.id}");
    getDoctors = getAllDoctors();
    getAllDoctorsWithLastMessages();
  }

  @override
  void dispose() {
    // Dispose of any resources like controllers, streams, etc.
    searchCtrl.dispose(); // Dispose of the search controller
    super.dispose();
  }

  TextEditingController searchCtrl = TextEditingController();

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
          getDoctors = getAllDoctors();
          getAllDoctorsWithLastMessages();
        },
        child: Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                TextField(
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
                  onChanged: (value) {
                    // If the query is empty, reload all users
                    if (value.isEmpty) {
                      getAllDoctors();
                    } else {
                      // Filter otherUsers based on the entered query
                      setState(() {
                        doctors = doctors.where((user) =>
                          user.doctorName!.toLowerCase().contains(value.toLowerCase())
                        ).toList();
                      });
                    }
                  },
                ),
            
                const SizedBox(height: 10.0,),
            
                GradientText(
                    'Available doctors',
                    style: GoogleFonts.poppins(
                        fontSize: 20.0, fontWeight: FontWeight.w600
                    ),
                    colors: [
                        Color(0xFF301847), Color(0xFFC10214)
                    ],
                ),
                
            
                FutureBuilder<void>(
                  future: getDoctors,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: doctors.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final user = doctors[index];
                              return Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Your existing InkWell code...
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context, MaterialPageRoute(
                                            builder: (context) => ChatWifDoctorRoom(patientId: widget.id ?? 0, doctorId: user.doctorID,)
                                          )
                                        );
                                      },
                                      child: Card(
                                        elevation: 5,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: profileImages.isNotEmpty && index < profileImages.length && profileImages[index] != null
                                                      ? DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: MemoryImage(profileImages[index]!)
                                                        )
                                                      : DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage(imageUrl)
                                                        ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              GradientText(doctors.isNotEmpty ? user.doctorName : "", 
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                ),
                                                colors: [
                                                  Color(0xFF301847), Color(0xFFC10214)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),

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
              
                FutureBuilder<void>(
                  future: getDoctors,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              if (index < doctors.length && index < lastMessages.length) {
                                final user = doctors[index];
                                final lastMessage = lastMessages[index];

                                //Split the timestamp into date and time components
                                List<String> components = lastMessage['timestamp'].toString().split(' ');
                                // Extract date and time components
                                print(components);
                                String date = components.first; 
                                // Get the current date
                                DateTime currentDate = DateTime.now();
                                DateTime? localDateTime;
                                // Initialize localDateTime based on the extracted date string
                                try {
                                  localDateTime = DateTime.parse(date).toLocal();
                                } catch (e) {
                                  print('Error parsing date: $e');
                                }
                                String formattedDate = '';
                                // Check if localDateTime is not null
                                if (localDateTime != null) {
                                  // Check if the date is today
                                  if (localDateTime.year == currentDate.year &&
                                      localDateTime.month == currentDate.month &&
                                      localDateTime.day == currentDate.day) {
                                    formattedDate = 'Today';
                                  } 
                                  // Check if the date is yesterday
                                  else if (localDateTime.year == currentDate.year &&
                                      localDateTime.month == currentDate.month &&
                                      localDateTime.day == currentDate.day - 1) {
                                    formattedDate = 'Yesterday';
                                  } 
                                  // Otherwise, display the date
                                  else {
                                    formattedDate = "${localDateTime.day.toString()}/${localDateTime.month.toString()}/${localDateTime.year}";
                                  }
                                } else {
                                  // Handle case where localDateTime is null (e.g., if parsing the date string fails)
                                  print('localDateTime is null');
                                }
                                                      
                                //String formattedTime = convertTo12HourFormat(lastMessageData['timestamp']);
                                print('Date Original: $date');
                                print('Date: $formattedDate');
                                print('Time: ${components.last}');
                                List<String> items = components.last.split(':');
                                print(items);
                                var hour;
                                var minute;
                                String formattedTime = "",  meridiem = "";
                                if(lastMessages.isNotEmpty){
                                  hour = items.length > 1 ? int.parse(items.first) : '';
                                  minute = items.length > 1 ? items.elementAt(1) : '';
                                  print("$hour: $minute");
                                  // Determine the meridiem (AM or PM)
                                  if(hour != ""){
                                    meridiem = hour < 12 ? 'AM' : 'PM';
                                    // Convert the hour to 12-hour format
                                    if (hour > 12) {
                                      hour -= 12; // Convert to 12-hour format
                                    } else if(hour == 0){
                                      hour = 12;
                                    }
                                    // Format the time string
                                    formattedTime = '$hour:${minute.toString().padLeft(2, '0')} $meridiem';
                                  }
                                  
                                }
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          Navigator.push(
                                            context, MaterialPageRoute(
                                              builder: (context) => ChatWifDoctorRoom(patientId: widget.id ?? 0, doctorId: user.doctorID,)
                                            )
                                          );
                                        },
                                        child: Card(
                                          elevation: 5,
                                          child: ListTile(
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: profileImages.isNotEmpty && index < profileImages.length && profileImages[index] != null
                                                    ? DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: MemoryImage(profileImages[index]!)
                                                      )
                                                    : DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage(imageUrl)
                                                      ),
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                GradientText(doctors.isNotEmpty ? user.doctorName : "", 
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18, fontWeight: FontWeight.w500
                                                  ),
                                                  colors: [
                                                    Color(0xFF301847), Color(0xFFC10214)
                                                  ],
                                                ),

                                                Spacer(),

                                                Text(
                                                  formattedDate == "Today" ? formattedTime : formattedDate,
                                                  style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 11.0
                                                ),),
                                              ],
                                            ),
                                            subtitle: Text(
                                              lastMessage['message'] ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                              ),
                                            ),

                                           

                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              else {
                                return Container();
                              }
                              
                            },
                          ),
                        ),
                      );
                    }
                  }
                 )
            
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}