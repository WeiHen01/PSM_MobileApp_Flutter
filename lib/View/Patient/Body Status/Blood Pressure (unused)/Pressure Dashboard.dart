import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../Model/GraphData.dart';

class PressureDashboard extends StatefulWidget {
  const PressureDashboard({super.key});

  @override
  State<PressureDashboard> createState() => _PressureDashboardState();
}

class _PressureDashboardState extends State<PressureDashboard> {

  DateTime? selectedDay;
  late DateTime focusedDay = DateTime.now(); // Add this line to store the focused day

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusedDay = DateTime.now(); // Initialize focused day to current date
  }

  CalendarFormat _calendarFormat = CalendarFormat.week; // Define calendarFormat variable

  String viewType = 'Months'; // Default view type
  
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

        title: Text("Pressure", style: GoogleFonts.poppins(
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
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                TableCalendar(
                  rowHeight: 55,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2070, 12, 31),
                  // Specify available calendar formats
                  availableCalendarFormats: {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.week: 'Week',
                  },
                  // Change calendar format callback
                  calendarFormat: _calendarFormat, // Start with week view by default
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  focusedDay: focusedDay, // Use the focusedDay variable here
                  selectedDayPredicate: (day) {
                    return isSameDay(day, selectedDay);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      // Here, 'selectedDay' contains the date selected on the calendar
                      print('Selected day: $selectedDay');
                      // You can perform any actions with the selected date here
                      this.selectedDay = selectedDay;
                      focusedDay = selectedDay;
                      this.focusedDay = selectedDay; // Update focusedDay to selectedDay
                    });
                  },
                  calendarStyle: CalendarStyle(
                    tablePadding: EdgeInsets.symmetric(vertical: 10.0),
                    outsideTextStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 20.0
                    ),
                    weekendTextStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20.0
                    ),
                    defaultTextStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20.0
                    ),
                    todayTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white,
                      fontSize: 20.0
                    ),
                    selectedTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white,
                      fontSize: 20.0
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFFF4081), // Change the color here
                      shape: BoxShape.circle, // You can change the shape if desired
                      
                    ),

                    // decoration for today
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFFF7F50), // Change the color here
                      shape: BoxShape.circle, // You can change the shape if desired
                    ),
                  ),
                  headerVisible: true,
                  daysOfWeekHeight: 30,
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF7F50),
                    ),
                    titleTextStyle: GoogleFonts.poppins(
                      color: Colors.black, fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    ),
                    formatButtonVisible: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Color(0xFFFF4081),
                      border: Border.fromBorderSide(
                        BorderSide(width: 2),
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    formatButtonTextStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0
                    ),
                  ),
                  
                  pageJumpingEnabled: true,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    
                    weekdayStyle: GoogleFonts.poppins(
                      color: Colors.black, fontWeight: FontWeight.w600,
                      fontSize: 20.0
                    ),
                    weekendStyle: GoogleFonts.poppins(
                      color: Colors.black, fontWeight: FontWeight.w600,
                      fontSize: 20.0
                    ),
                    
                  ),
                  
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Analytics", style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: Colors.black,
                              fontSize: 20.0
                            ),),
                          ),

                          Spacer(), 

                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                viewType = 'Days';
                              });
                            },
                            child: Text('Days', style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600,
                              fontSize: 15.0
                            ),),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Add logic to switch to view based on months
                              setState(() {
                                viewType = 'Months';
                              });
                            },
                            child: Text('Months', style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600,
                              fontSize: 15.0
                            ),),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Add logic to switch to view based on years
                              setState(() {
                                viewType = 'Years';
                              });
                            },
                            child: Text('Years', style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600,
                              fontSize: 15.0
                            ),),
                          ),
                        ],
                      ),

                      SfCartesianChart(
                        // Initialize category axis
                        primaryXAxis: viewType == 'Months'
                        ? CategoryAxis(
                            // For months view
                            labelStyle: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0),
                            title: AxisTitle(
                              text: 'Month',
                              textStyle: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.0),
                            ),
                          )
                        : viewType == 'Days'
                            ? CategoryAxis(
                                // For days view
                                labelStyle: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.0),
                                title: AxisTitle(
                                  text: 'Day',
                                  textStyle: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0),
                                ),
                              )
                            : CategoryAxis(
                                // For years view
                                labelStyle: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.0),
                                title: AxisTitle(
                                  text: 'Year',
                                  textStyle: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0),
                                ),
                              ),

                        primaryYAxis: NumericAxis(
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.w600,
                            fontSize: 15.0
                          ),
                          title: AxisTitle(
                            text: 'Pascal', // Set the label for X axis
                            textStyle:  GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600,
                              fontSize: 15.0
                            ),
                          ),
                        ),

                        
                        title: ChartTitle(
                          text: 'Blood Pressure Record ${
                            viewType == 'Months' 
                            ? 'By Year 2023' 
                            : viewType == 'Days' 
                              ? 'By Feb 2023' 
                              : 'From year 2018 - year 2023'
                          }',
                          textStyle:  GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.w600,
                            fontSize: 15.0
                          ),
                        ),
                        
                        series: <LineSeries<GraphData, String>>[
                          LineSeries<GraphData, String>(
                            color: Colors.orange,
                            // Bind data source
                            dataSource:  viewType == 'Months'
                            ? <GraphData>[
                                GraphData(month: 'Jan', value: 25),
                                GraphData(month: 'Feb', value: 28),
                                GraphData(month: 'Mar', value: 34),
                                GraphData(month: 'Apr', value: 32),
                                GraphData(month: 'May', value: 40),
                                GraphData(month: 'Jun', value: 25),
                                GraphData(month: 'Jul', value: 28),
                                GraphData(month: 'Aug', value: 34),
                                GraphData(month: 'Sep', value: 32),
                                GraphData(month: 'Oct', value: 40),
                                GraphData(month: 'Nov', value: 25),
                                GraphData(month: 'Dec', value: 28),
                              ]
                          : viewType == 'Days'
                              ? <GraphData>[
                                  GraphData(day: 'Day 1', value: 15),
                                  GraphData(day: 'Day 2', value: 38),
                                  GraphData(day: 'Day 3', value: 40),
                                  GraphData(day: 'Day 4', value: 22),
                                  GraphData(day: 'Day 5', value: 30)
                                ]
                              : <GraphData>[
                                  GraphData(year: '2020', value: 5),
                                  GraphData(year: '2021', value: 8),
                                  GraphData(year: '2022', value: 14),
                                  GraphData(year: '2023', value: 12),
                                  GraphData(year: '2024', value: 10)
                                ],
                            xValueMapper: (GraphData value, _) => 
                              viewType == 'Days'
                              ? value.day
                              : viewType == 'Months'
                                ? value.month
                                : value.year,
                            yValueMapper: (GraphData value, _) => value.value,
                            dataLabelSettings: DataLabelSettings(isVisible: true)
                          )
                        ],
                        // Enable legend
                        

                        
                        
                        
                      )
                    ],
                  ),
                ),



              ],
            )
          ),
        )
      )
    );
  }
}
