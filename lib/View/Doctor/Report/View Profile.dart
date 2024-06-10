//import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

//import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:gradient_borders/gradient_borders.dart';
//import 'package:local_ip_plugin/local_ip_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
//import 'package:network_info_plus/network_info_plus.dart';

//import '../../../Controller/Request Controller.dart';
import '../../../Controller/MongoDBController.dart';
import '../../../Model/Heart Pulse.dart';
import '../../../Model/Temperature.dart';

class ViewProfile extends StatefulWidget {
  
  final int? id;

  ViewProfile({Key? key, this.id});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {

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
  
  // Function to format DateTime to string
  String formatDate(String date) {
    // Parse the date string
    final dateTime = DateTime.parse(date);
    // Format the DateTime into a desired string format
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  // Function to format Time to string in 12-hour system and convert to local time
  String formatTime(String time) {
    final dateTime = DateTime.parse(time).toLocal(); // Convert to local time
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0'); // Add leading zero if necessary
    final second = dateTime.second.toString().padLeft(2, '0'); // Add leading zero if necessary
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute:$second $period';
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

  late List<Temperature> temperatures = [];
  late List<Pulse> pulses = [];

  Future<void> getAllTempRecordsByToday() async {

    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var temp = await MongoDatabase().getByQuery("Temperature", 
        {
          "PatientID" : 'P-${widget.id}'
        }
      );
      print("All Temperature: $temp");
      print("Total: ${temp.length}");
      
      if(temp.isNotEmpty){
        setState((){
          temperatures = temp.map((json) => Temperature.fromJson(json)).toList();
          
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

  Future<void> getAllPulseRecordsByToday() async {

    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulseRecord = await MongoDatabase().getByQuery("Heart_Pulse", 
        {
          "PatientID" : 'P-${widget.id}',
          
        }
      );
      print("All Temperature: $pulseRecord");
      print("Total: ${pulseRecord.length}");
      
      if(pulseRecord.isNotEmpty){
        setState((){
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
          
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MongoDatabase db = MongoDatabase();
    db.open("Patient");
    getProfile();
    fetchProfileImage();
    getAllPulseRecordsByToday();
    getAllTempRecordsByToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("Patient Profile", style: GoogleFonts.poppins(
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
                getAllPulseRecordsByToday();
                getAllTempRecordsByToday();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
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
                                                
                                  /* Row(
                                    children: [
                                      Text("Description", style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                        )
                                      ),
                                    ],
                                  ), */
                
                                  const SizedBox(height: 20.0),
                                            
                                                
                                  
                                                
                                  
                                                
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                
                      const SizedBox(height: 20.0),

                     Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Temperature", style: GoogleFonts.poppins(
                                  fontSize: 15.0, fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(width: 2.0),
                                  ),
                                  headingRowHeight: 30,
                                  columnSpacing: MediaQuery.sizeOf(context).width * 0.06,
                                  
                                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.pink),
                                  headingTextStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, color: Colors.white,
                                    fontSize: 12.0
                                  ),
                                  dataTextStyle: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12.0
                                  ),
                                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Set background color for data rows
                                  columns: [
                                    DataColumn(label: Container(width: 50, padding: EdgeInsets.zero, child: Text('Date'))),
                                    DataColumn(label: Text('Time')),
                                    DataColumn(label: Text('Temperature')),
                                  ],
                                  rows: temperatures.map((user) {
                                    return DataRow(cells: [
                                      DataCell(Container(width: 50, padding: EdgeInsets.zero, child: Text("${formatDate(user.measureDate.toString())}"))),
                                      DataCell(Container(width: 50, padding: EdgeInsets.zero, child: Text("${formatTime(user.measureTime.toString())}"))),
                                      DataCell(Text("${user.temperature}")),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                
                            const SizedBox(height: 20.0),
                
                            
                          ],
                        )
                      ),

                      const SizedBox(height: 20.0),
              
              
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Heart Pulse", style: GoogleFonts.poppins(
                                  fontSize: 15.0, fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                      
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(width: 2.0),
                                  ),
                                  headingRowHeight: 30,
                                  columnSpacing: MediaQuery.sizeOf(context).width * 0.1,
                                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.pink),
                                  headingTextStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, color: Colors.white,
                                    fontSize: 12.0
                                  ),
                                  dataTextStyle: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12.0
                                  ),
                                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Set background color for data rows
                                  columns: [
                                    DataColumn(label: Container(width: 50, padding: EdgeInsets.zero, child: Text('Date'))),
                                    DataColumn(label: Container(child: Text('Time'))),
                                    DataColumn(label: Container(child: Text('Pulse'))),
                                  ],
                                  rows: pulses.map((user) {
                                    return DataRow(cells: [
                                      DataCell(Container(width: 50, padding: EdgeInsets.zero, child: Text("${formatDate(user.MeasureDate.toString())}"))),
                                      DataCell(Container(width: 50, child: Text("${formatTime(user.MeasureTime.toString())}"))),
                                      DataCell(Text("${user.pulseRate}")),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            

                          ],
                        )
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