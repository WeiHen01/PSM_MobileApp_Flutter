import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'View Profile.dart';

import '../../../Controller/MongoDBController.dart';
import '../../../Model/Patient.dart';
class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {

  int? highestTemperature;

  Future<void> getHighestTempRecordsByToday() async {
    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var temp = await MongoDatabase().getByQuery("Temperature", {
        "MeasureDate": {
          "\$gte": today, // Change to today
          "\$lt": today.add(Duration(days: 1)),
        }
      });

      print("All Temperature: $temp");
      print("Total: ${temp.length}");

      if (temp.isNotEmpty) {
        // Sort the temperature records by temperature value in descending order
        temp.sort((a, b) => b['Temperature'].compareTo(a['Temperature']));
        
        // Get the highest temperature record
        var highestTempRecord = temp.first;

        setState(() {
          // Update the state with the highest temperature value
          // Extract the highest temperature value
          highestTemperature = highestTempRecord['Temperature'];
        });
      }
    } catch (e, printStack) {
      print('Error fetching highest temperature records: $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  int? highestPulse;

  Future<void> getHighestPulseToday() async {
    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulse = await MongoDatabase().getByQuery("Heart_Pulse", {
        "MeasureDate": {
          "\$gte": today, // Change to today
          "\$lt": today.add(Duration(days: 1)),
        }
      });

      print("All Pulse: $pulse");
      print("Total: ${pulse.length}");

      if (pulse.isNotEmpty) {
        // Sort the temperature records by temperature value in descending order
        pulse.sort((a, b) => b['PulseRate'].compareTo(a['PulseRate']));
        
        // Get the highest temperature record
        var highestPulseRecord = pulse.first;

        setState(() {
          // Update the state with the highest temperature value
          // Extract the highest temperature value
          highestPulse = highestPulseRecord['PulseRate'];
        });
      }
    } catch (e, printStack) {
      print('Error fetching highest temperature records: $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  int? totalPatients;
  int _rowsPerPage = 5; // Default rows per page
  List<Patient> allPatients = [];
  Future<void> getTotalPatients() async {
    
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var patients = await MongoDatabase().getByQuery("Patient", {});

      print("All Patients Records: $patients");
      print("Total Patients Records: ${patients.length}");

      setState(() {
        // Update the state with the total number of pulse records
        totalPatients = patients.length;
        allPatients = patients.map((json) => Patient.fromJson(json)).toList();

        print(allPatients);
      });
    } catch (e, printStack) {
      print('Error fetching pulse records: $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHighestTempRecordsByToday();
    getHighestPulseToday();
    getTotalPatients();
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


        title: Text("Report", style: GoogleFonts.poppins(
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
          getHighestTempRecordsByToday();
          getHighestPulseToday();
          getTotalPatients();
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Report", style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black,
                          fontSize: 20.0
                        ),),
                      ),
            
                      SizedBox(height: 10),
            
                      Container(
                        height: 150,
                        child: ListView.separated(
                          separatorBuilder: (context, builder) {
                            return SizedBox(width: 10,);
                          }, 
                          itemCount: 3,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                            
                        
                            if(index == 0){
                              return Card(
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                
                                height: 80,
                                width: MediaQuery.of(context).size.width / 3.8,
                                child: Column(
                                  children: [
                                    
                                    Text("Highest Temperature Today Record", style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.0
                                    ), textAlign: TextAlign.justify,),
                                        
                                    Spacer(),
                                        
                                    Text("${highestTemperature ?? "-"}", style: GoogleFonts.poppins(
                                      color: Colors.white, fontWeight: FontWeight.w700,
                                      fontSize: 20.0
                                    ),),
                                        
                                  ],
                                ),
                              ),
                            );
                            }
                            else if(index == 1){
                              return  Card(
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                
                                height: 80,
                                width: MediaQuery.of(context).size.width / 3.8,
                                child: Column(
                                  children: [
                                    
                                    Text("Highest Pulse Today Record", style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.0
                                    ), textAlign: TextAlign.justify,),
                                        
                                    Spacer(),
                                        
                                    Text("${highestPulse ?? "-"}", style: GoogleFonts.poppins(
                                      color: Colors.white, fontWeight: FontWeight.w700,
                                      fontSize: 20.0
                                    ),),
                                        
                                  ],
                                ),
                              ),
                            );
                            }
                            else {
                              return Card(
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                
                                height: 80,
                                width: MediaQuery.of(context).size.width / 3.8,
                                child: Column(
                                  children: [
                                    
                                    Text("Total Patients", style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.0
                                    ), textAlign: TextAlign.justify,),
                                        
                                    Spacer(),
                                        
                                    Text("${totalPatients ?? 0}", style: GoogleFonts.poppins(
                                      color: Colors.white, fontWeight: FontWeight.w700,
                                      fontSize: 20.0
                                    ),),
                                    
                                  ],
                                ),
                              ),
                            );
                            }
                                
                          }
                        ),
                      ),
            
                      SizedBox(height: 20),
            
                      
                      _buildPaginatedTable(),

                        
                      

                      SizedBox(height: 20),
                      

                      


                    ]
                  )
                ),
            
            
            
            
              ]
            ),
          )
        ),
      )

    );

    
  }

  Widget _buildPaginatedTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaginatedDataTable(
          header: GradientText(
            colors: [
              Color(0xFF301847), Color(0xFFC10214)
            ],
            "All Patients",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18, color: Colors.white,
            ),
          ),
          headingRowColor: WidgetStatePropertyAll(Colors.pink),
          columns: [
            DataColumn(label: Text("Patient", style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white,
              fontSize: 18,
            ),)),
            DataColumn(label: Text("Profile", style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white,
              fontSize: 18,
            ),)),
          ],
          source: PatientDataSource(allPatients, context),
          rowsPerPage: _rowsPerPage,
          columnSpacing: 20,
          horizontalMargin: 10,
          showCheckboxColumn: false,
          actions: [
            DropdownButton<int>(
              value: _rowsPerPage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rowsPerPage = value;
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
}

  




class PatientDataSource extends DataTableSource {
  final List<Patient> patients;
  final BuildContext context;

  PatientDataSource(this.patients, this.context);

  @override
  DataRow getRow(int index) {
    final patient = patients[index];
    return DataRow(cells: [
      DataCell(Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.patientName,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(patient.patientEmail, style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 12.0, 
              ),
            ),
          ],
        ),
      )),
      DataCell(IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfile(id: patient.patientID),
            ),
          );
        },
        icon: Icon(Icons.account_box),
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => patients.length;

  @override
  int get selectedRowCount => 0;
}