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
   int _rowsPulsePerPage = 5; // Default rows per page
   int _rowsTempPerPage = 5; // Default rows per page

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
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                
                
                             buildPaginatedTemperatureTable(),
                
                            const SizedBox(height: 20.0),
                
                            
                          ],
                        )
                      ),

                      const SizedBox(height: 20.0),
              
              
                      Container(
                         width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                
                      
                           buildPaginatedPulseTable(),

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

  Widget buildPaginatedTemperatureTable() {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaginatedDataTable(
          header: Text('Temperature Records', style: GoogleFonts.poppins(fontSize: 15.0, fontWeight: FontWeight.bold)),
          columns: [
            DataColumn(label: Text('Date', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
            DataColumn(label: Text('Time', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
            DataColumn(label: Text('Temperature', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
          ],
          source: TemperatureDataSource(temperatures, formatDate, formatTime),
          rowsPerPage: _rowsTempPerPage,
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.pink),
          actions: [
            DropdownButton<int>(
              value: _rowsTempPerPage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rowsTempPerPage = value;
                  });
                }
              },
              items: [5, 10]
                  .map((e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text("$e rows per page", style: GoogleFonts.poppins(
                          fontSize: 13
                        )),
                      ))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPaginatedPulseTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaginatedDataTable(
          header: Text('Pulse Records', style: GoogleFonts.poppins(fontSize: 15.0, fontWeight: FontWeight.bold)),
          columns: [
            DataColumn(label: Text('Date', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
            DataColumn(label: Text('Time', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
            DataColumn(label: Text('Pulse Rate', style: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white,))),
          ],
          headingRowColor: WidgetStateProperty.all(Colors.pink),
          source: PulseDataSource(pulses, formatDate, formatTime),
          rowsPerPage: _rowsPulsePerPage,
          columnSpacing: 20,
          actions: [
            DropdownButton<int>(
              value: _rowsPulsePerPage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rowsPulsePerPage = value;
                  });
                }
              },
              items: [5, 10]
                  .map((e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text("$e rows per page", style: GoogleFonts.poppins(
                          fontSize: 13
                        )),
                      ))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  // Function to format DateTime to string
  String formatDate(String date) {
    final dateTime = DateTime.parse(date).toLocal();
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  // Function to format Time to string in 12-hour system and convert to local time
  String formatTime(String time) {
    final dateTime = DateTime.parse(time).toLocal();
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute:$second $period';
  }
}

class TemperatureDataSource extends DataTableSource {
  final List<Temperature> temperatures;
  final Function formatDate;
  final Function formatTime;

  TemperatureDataSource(this.temperatures, this.formatDate, this.formatTime);

  @override
  DataRow? getRow(int index) {
    if (index >= temperatures.length) return null;

    final temperature = temperatures[index];
    return DataRow(cells: [
      DataCell(Text("${formatDate(temperature.measureDate.toString())}", style: GoogleFonts.poppins(fontSize: 12.0))),
      DataCell(Text("${formatTime(temperature.measureTime.toString())}", style: GoogleFonts.poppins(fontSize: 12.0))),
      DataCell(Text(temperature.temperature.toString(), style: GoogleFonts.poppins(fontSize: 12.0))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => temperatures.length;

  @override
  int get selectedRowCount => 0;
}

class PulseDataSource extends DataTableSource {
  final List<Pulse> pulses;
  final Function formatDate;
  final Function formatTime;

  PulseDataSource(this.pulses, this.formatDate, this.formatTime);

  @override
  DataRow? getRow(int index) {
    if (index >= pulses.length) return null;

    final pulse = pulses[index];
    return DataRow(cells: [
      DataCell(Text("${formatDate(pulse.MeasureDate.toString())}", style: GoogleFonts.poppins(fontSize: 12.0))),
      DataCell(Text("${formatTime(pulse.MeasureTime.toString())}", style: GoogleFonts.poppins(fontSize: 12.0))),
      DataCell(Text(pulse.pulseRate.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => pulses.length;

  @override
  int get selectedRowCount => 0;
}