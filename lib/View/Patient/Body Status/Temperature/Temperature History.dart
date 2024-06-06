import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Controller/MongoDBController.dart';
import '../../../../Model/Temperature.dart';

class TempHistory extends StatefulWidget {
  final int? id;
  const TempHistory({super.key, this.id});

  @override
  State<TempHistory> createState() => _TempHistoryState();
}

class _TempHistoryState extends State<TempHistory> {

  late List<Temperature> temperatures = [];
  Future<void> getAllTempRecords() async {
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var temp = await MongoDatabase().getByQuery("Temperature", {"PatientID" : 'P-${widget.id}'});
      print("All: $temp");
      
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTempRecords();
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

        title: Text("Temperature", style: GoogleFonts.poppins(
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
                  itemCount: temperatures.length,
                  itemBuilder: (context, index){
                    final records = temperatures[index];

                    return InkWell(
                      // Access the temperature record at the current index
                      
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
                                Text("${formatDate(records.measureDate.toString())} ${formatTime(records.measureTime.toString())}", style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12.0
                                ),),
                                            
                                
                              ],
                            ),
                      
                            SizedBox(height: 15),
                                            
                                            
                            Row(
                              children: [
                                Text(records.temperature.toString(), style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, color: Colors.black,
                                  fontSize: 20.0
                                ),),
                                            
                                SizedBox(width: 10),
                                            
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("°C", style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, color: Colors.black,
                                      fontSize: 10
                                    ),),
                                            
                                    Text("Degree Celsius", style: GoogleFonts.poppins(
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