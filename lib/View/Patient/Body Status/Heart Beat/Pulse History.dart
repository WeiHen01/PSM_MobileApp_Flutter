import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Controller/MongoDBController.dart';
import '../../../../Model/Heart Pulse.dart';

class PulseHistory extends StatefulWidget {
  final int? id;
  const PulseHistory({super.key, this.id});

  @override
  State<PulseHistory> createState() => _PulseHistoryState();
}

class _PulseHistoryState extends State<PulseHistory> {

  late List<Pulse> pulses = [];
  Future<void> getAllPulseRecords() async {
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulse = await MongoDatabase().getByQuery("Heart_Pulse", {"PatientID" : 'P-${widget.id}'});
      print("All: $pulse");
      
      if(pulse.isNotEmpty){
        setState((){
          pulses = pulse.map((json) => Pulse.fromJson(json)).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other pulse : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPulseRecords();
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
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $period';
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

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),

        title: Text("Heart Pulse", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),

        

      ),

      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: ()async {
          // Simulate a time-consuming task
          await Future.delayed(Duration(seconds: 1));
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("History", style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black,
                  fontSize: 20.0
                ),),
              ),

              Expanded(
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 15); // Adjust the height as needed
                  },
                  reverse: true,
                  itemCount: pulses.length,
                  itemBuilder: (context, index){

                    final records = pulses[index];

                    return InkWell(
                      onLongPress: (){
                        
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 224, 224, 224),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade600,
                              offset: Offset(2, 2),
                              spreadRadius: 1.0,
                              blurRadius: 2.0,
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("${formatDate(records.MeasureDate.toString())} ${formatTime(records.MeasureTime.toString())}", style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12.0
                                ),),
                              
                                
                              ],
                            ),
                      
                            SizedBox(height: 15),
                                            
                                            
                            Row(
                              children: [
                                Text("${records.pulseRate}", style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, color: Colors.black,
                                  fontSize: 20.0
                                ),),
                                            
                                SizedBox(width: 10),
                                            
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("BPM", style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, color: Colors.black,
                                      fontSize: 10
                                    ),),
                                            
                                    Text("Pulse Rate", style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 10
                                    ),),
                                  ],
                                )
                              ],
                            ),
                                            
                            
                                            
                                            
                          ],
                        ),
                      ),
                    );
                  }
                
                ),
              ),
            ],
          )
        )
      )
    );
  }
}