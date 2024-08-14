import 'package:calendar_date_picker2/calendar_date_picker2.dart';
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
  late List<Pulse> filteredPulses = []; // Added filtered pulses list
  Future<void> getAllPulseRecords() async {
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var pulse = await MongoDatabase().getByQuery("Heart_Pulse", {"PatientID" : 'P-${widget.id}'});
      print("All: $pulse");
      
      if(pulse.isNotEmpty){
        setState((){
          pulses = pulse.map((json) => Pulse.fromJson(json)).toList();
          filteredPulses = List.from(pulses);
        });
      }

    } catch (e, printStack) {
      print('Error fetching other pulse : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }


  // add function to display list based on certain day
  void filterPulsesByDate(DateTime? date) {
    setState(() {
      if (date != null) {
        filteredPulses = pulses.where((record) {
          final recordDate = DateTime.parse(record.MeasureDate.toString());
          return recordDate.year == date.year &&
                 recordDate.month == date.month &&
                 recordDate.day == date.day;
        }).toList();
      } else {
        filteredPulses = List.from(pulses); // Reset to all records if no date is selected
      }
    });
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

  // Function to get the day of the week
  String getDayOfWeek(String date) {
    final dateTime = DateTime.parse(date);
    final dayOfWeek = dateTime.weekday;
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  DateTime? selectedDate;

   // List of month names
  final List<String> monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  
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
          getAllPulseRecords();
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("History", style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white,
                      fontSize: 20.0
                    ),),

                    Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: ()async{
                        var date_result = await showCalendarDatePicker2Dialog(
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(
                            controlsTextStyle:  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                            weekdayLabelTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                            lastMonthIcon: Icon(Icons.arrow_back_ios, color: Colors.black),
                            nextMonthIcon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                            selectedDayHighlightColor: Color(0xFFFF4081),
                            dayTextStyle: GoogleFonts.poppins(color: Colors.black),
                            monthTextStyle: GoogleFonts.poppins(color: Color(0xFF000000)),
                            yearTextStyle: GoogleFonts.poppins(color: Colors.black),
                            okButtonTextStyle: GoogleFonts.poppins(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
                            selectedMonthTextStyle: GoogleFonts.poppins(color: Colors.white),
                            selectedDayTextStyle: GoogleFonts.poppins(color: Colors.white),
                            cancelButtonTextStyle:  GoogleFonts.poppins(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),

                          ),
                          dialogSize: const Size(325, 400),
                          value: [selectedDate],
                          borderRadius: BorderRadius.circular(15),
                          
                        );

                        // If results are not null and contain at least one date, update the selected date
                        if (date_result != null) {
                          setState(() {
                            
                            selectedDate = date_result.last; // Update selected date to the first (and only) selected date
                            filterPulsesByDate(selectedDate!);
                          });
                          print("Selected Date: ${selectedDate.toString()}"); // Print the selected date
                          
                        }
                        else{
                          selectedDate = null;
                          filterPulsesByDate(null);
                        }
                        
                      },
                      child: Row(
                        children: [
                          Text("${selectedDate == null ? "-" : "${selectedDate!.day.toString()} ${monthNames[selectedDate!.month - 1]} ${selectedDate!.year.toString()}"} ", style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0
                          ),),

                          Icon(Icons.arrow_drop_down_sharp, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 15); // Adjust the height as needed
                  },
                  reverse: false,
                  itemCount: filteredPulses.length,
                  itemBuilder: (context, index){

                    final records = filteredPulses[index];

                    return Card(
                    
                      elevation: 3,
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${formatDate(records.MeasureDate.toString())}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13.0, fontWeight: FontWeight.bold,
                              ),
                            ),
                                                
                            Text(
                              "${getDayOfWeek(records.MeasureDate.toString())}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            ),
                                                
                           
                          ]
                        ),
                        title: Row(
                          children: [
                            Text(
                              "${formatTime(records.MeasureTime.toString())}",
                              style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13.0
                            ),),

                            Spacer(),
                            

                             Visibility(
                              visible: (records.pulseRate < 183 && records.pulseRate > 142 || records.pulseRate > 183 || records.pulseRate < 60) ? true : false,
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  color: (records.pulseRate > 183) 
                                          ? Color(0xFFD30E00) 
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? Color(0xFFFF5100)
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? Colors.orange
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? Color(0xFF00DF0B)
                                          : Color(0xFFFBFF00),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                padding: EdgeInsets.all(5.0),
                                
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      
                                       records.pulseRate > 183 
                                          ? Icons.warning_amber
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? Icons.arrow_drop_up
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? Icons.trending_up
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? Icons.check
                                          : Icons.trending_down,
                                      
                                      size: 15.0,
                                    ),
                                    SizedBox(width: 5),
                                    Text(records.pulseRate > 183 
                                          ? 'Danger'
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? 'Maximum'
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? 'Healthy'
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? 'Average'
                                          : 'Lower'
                                          , style: GoogleFonts.poppins(
                                      color: (records.pulseRate > 183) 
                                          ? Color(0xFFFFFFFF) 
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? Color(0xFFFFFFFF)
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? Color(0xFF000000)
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? Color(0xFF000000)
                                          : Color(0xFF000000),
                                      fontSize: 12.0
                                    ),),
                                  ],
                                ),
                              )
                            ),

                            SizedBox(width: 5),


                            Container(
                              padding: EdgeInsets.all(5.0),
                              width: 70,
                              decoration: BoxDecoration(
                                color: (records.pulseRate > 183) 
                                          ? Color(0xFFD30E00) 
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? Color(0xFFFF5100)
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? Colors.orange
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? Color(0xFF00DF0B)
                                          : Color(0xFFFBFF00),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Text("${records.pulseRate.toString()} BPM", style: GoogleFonts.poppins(
                                color: (records.pulseRate > 183) 
                                          ? Color(0xFFFFFFFF) 
                                          : (records.pulseRate < 183 && records.pulseRate > 142) 
                                          ? Color(0xFFFFFFFF)
                                          : (records.pulseRate <= 142 && records.pulseRate > 102) 
                                          ? Color(0xFF000000)
                                          : (records.pulseRate <= 102 && records.pulseRate > 60)
                                          ? Color(0xFF000000)
                                          : Color(0xFF000000),
                                fontSize: 12.0
                              ), textAlign: TextAlign.center,),
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