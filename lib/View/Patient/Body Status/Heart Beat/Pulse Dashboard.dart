import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../Controller/MongoDBController.dart';
import '../../../../Model/GraphData.dart';
import '../../../../Model/Heart Pulse.dart';

class PulseDashboard extends StatefulWidget {
  final int? id;
  const PulseDashboard({super.key, this.id});

  @override
  State<PulseDashboard> createState() => _PulseDashboardState();
}





class _PulseDashboardState extends State<PulseDashboard> {


  final List<bool> _selectedDays = <bool>[true, false, false];
  bool vertical = false;

  late List<Pulse> pulses = [];
  List<GraphData> pulsesData = [];
  String graphTitle = '';

  String formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time).toLocal();
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute:$second $period';
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
          "MeasureDate": {
            "\$gte": today, //change to today
            "\$lt": today.add(Duration(days: 1)),
          }
        }
      );
      print("All Temperature: $pulseRecord");
      print("Total: ${pulseRecord.length}");
      
      if(pulseRecord.isNotEmpty){
        setState((){
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
                  detectPulsePattern();
                   // Calculate average, minimum, and maximum pulse rates
          double totalPulseRate = pulses.fold(0.0, (sum, rate) => sum + rate.pulseRate.toDouble());
          double averagePulseRate = totalPulseRate / pulses.length;
          double minPulseRate = pulses.map((rate) => rate.pulseRate.toDouble()).reduce((a, b) => a < b ? a : b);
          double maxPulseRate = pulses.map((rate) => rate.pulseRate.toDouble()).reduce((a, b) => a > b ? a : b);

          print("Average Pulse Rate: $averagePulseRate");
          print("Minimum Pulse Rate: $minPulseRate");
          print("Maximum Pulse Rate: $maxPulseRate");

          setState(() {
            avg = "${averagePulseRate.toStringAsFixed(2)}";
            max = "${maxPulseRate.toStringAsFixed(2)}";
            min = "${minPulseRate.toStringAsFixed(2)}";
          });


          pulsesData = pulses.map((rate) =>
              GraphData(day: formatTime(rate.MeasureTime.toString()), value: rate.pulseRate.toDouble())
          ).toList();
        });
      }
      else{
        setState((){
          pulses = pulseRecord.map((json) => Pulse.fromJson(json)).toList();
                  detectPulsePattern();
          pulsesData = pulses.map((rate) =>
              GraphData(day: formatTime(rate.MeasureTime.toString()), value: rate.pulseRate.toDouble())
          ).toList();
        });
      }

    } catch (e, printStack) {
      print('Error fetching other doctors : $e');
      print(printStack);
      // Handle the exception as needed, for example, show an error message to the user
    }

  }

   Future<void> getPulseRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startDate,
            "\$lt": endDate.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        pulses = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
                detectPulsePattern();
        print("Records between ${startDate} and ${endDate}: ${pulses}");
        pulsesData = pulses.map((rate) => GraphData(day: "${formatDate(rate.MeasureDate.toString())} ${formatTime(rate.MeasureTime.toString())}", value: rate.pulseRate.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching pulse records: $e');
      print(printStack);
    }
  }


  Future<void> getHighestPulseRecordsForRecentDays() async {
    setState(() {
      graphTitle = "Highest Pulse records for Recent 5 days";
    });
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime fiveDaysAgo = today.subtract(Duration(days: 5));

    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": fiveDaysAgo,
            "\$lt": today.add(Duration(days: 1)),
          }
        },
      );

      List<Pulse> rates = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
      Map<DateTime, Pulse> highestRates = {};

      for (var rate in rates) {
        DateTime date = DateTime(rate.MeasureDate!.year, rate.MeasureDate!.month, rate.MeasureDate!.day);
        if (!highestRates.containsKey(date) || highestRates[date]!.pulseRate < rate.pulseRate) {
          highestRates[date] = rate;

          print("Highest: ${highestRates[date]}");
        }
      }

      setState(() {
        pulses = highestRates.values.toList();
                detectPulsePattern();
        pulsesData = pulses.map((rate) => GraphData(day: formatDate(rate.MeasureDate.toString()), value: rate.pulseRate.toDouble())).toList();
      });
    } catch (e, printStack) {
      print('Error fetching temperature records: $e');
      print(printStack);
    }
  }

  String? avg, max, min;
  // Get records for a specific date and calculate the average, minimum, and maximum pulse rates
  Future<void> getPulseRecordsBySpecificDate(DateTime date) async {
    setState(() {
      graphTitle = "Records for ${date.day} ${monthNames[date.month - 1]} ${date.year}";
    });
    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": DateTime(date.year, date.month, date.day),
            "\$lt": DateTime(date.year, date.month, date.day).add(Duration(days: 1)),
          }
        },
      );

      if (pulseRecords.isNotEmpty) {
        // Map records to Pulse objects
        pulses = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
        detectPulsePattern();
        // Calculate average, minimum, and maximum pulse rates
        double totalPulseRate = pulses.fold(0.0, (sum, rate) => sum + rate.pulseRate.toDouble());
        double averagePulseRate = totalPulseRate / pulses.length;
        double minPulseRate = pulses.map((rate) => rate.pulseRate.toDouble()).reduce((a, b) => a < b ? a : b);
        double maxPulseRate = pulses.map((rate) => rate.pulseRate.toDouble()).reduce((a, b) => a > b ? a : b);

        // Update the graph data
        pulsesData = pulses.map((rate) => 
          GraphData(day: "${formatDate(rate.MeasureDate.toString())} ${formatTime(rate.MeasureTime.toString())}", value: rate.pulseRate.toDouble())
        ).toList();

        print("Average Pulse Rate: $averagePulseRate");
        print("Minimum Pulse Rate: $minPulseRate");
        print("Maximum Pulse Rate: $maxPulseRate");

        setState(() {
          

          avg = "${averagePulseRate.toStringAsFixed(2)}";
          max = "${maxPulseRate.toStringAsFixed(2)}";
          min = "${minPulseRate.toStringAsFixed(2)}";
        });
      } else {
        print("No pulse records found for the selected date.");
        // Handle the case where no records are found
      }
    } catch (e, printStack) {
      print('Error fetching pulse records for specific date: $e');
      print(printStack);
    }
  }


  Future<void> getPulseRecordsForWeek(DateTime date) async {
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1)); // Start of the week (Monday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // End of the week (Sunday)

    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startOfWeek,
            "\$lt": endOfWeek.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        pulses = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
         detectPulsePattern();
        pulsesData = pulses.map((rate) => GraphData(day: "${formatDate(rate.MeasureDate.toString())} ${formatTime(rate.MeasureTime.toString())}", value: rate.pulseRate.toDouble())).toList();
        graphTitle = "Pulse Records for Week of ${formatDate(startOfWeek.toString())} to ${formatDate(endOfWeek.toString())}";
      });
    } catch (e, printStack) {
      print('Error fetching pulse records for the week: $e');
      print(printStack);
    }
  }

  Future<void> getPulseRecordsForMonth(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1); // Start of the month
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0); // End of the month

    try {
      var pulseRecords = await MongoDatabase().getByQuery(
        "Heart_Pulse",
        {
          "PatientID": 'P-${widget.id}',
          "MeasureDate": {
            "\$gte": startOfMonth,
            "\$lt": endOfMonth.add(Duration(days: 1)),
          }
        },
      );

      setState(() {
        pulses = pulseRecords.map((json) => Pulse.fromJson(json)).toList();
        detectPulsePattern();
        pulsesData = pulses.map((rate) => GraphData(day: "${formatDate(rate.MeasureDate.toString())} ${formatTime(rate.MeasureTime.toString())}", value: rate.pulseRate.toDouble())).toList();
        graphTitle = "Pulse Records for ${monthNames[date.month - 1]} ${date.year}";
      });
    } catch (e, printStack) {
      print('Error fetching pulse records for the month: $e');
      print(printStack);
    }
  }

  String pulsePatternMessage = "";
  String suggestion = "";

  void detectPulsePattern() {
    bool hypokineticPulse = true;
    bool hyperkineticPulse = true;
    bool pulsusAlternans = false;
    bool bigeminalPulse = false;
    bool waterhammerPulse = false;
    bool pulsusBisferiens = false;

    double previousPulse = pulses.first.pulseRate.toDouble();
    double minPulse = double.infinity;
    double maxPulse = -double.infinity;
    bool firstPhase = true;
    bool pulseReturnedToNormal = false;

    for (var pulse in pulses) {
      double currentPulse = pulse.pulseRate.toDouble();

      // Track the min and max pulse
      minPulse = currentPulse < minPulse ? currentPulse : minPulse;
      maxPulse = currentPulse > maxPulse ? currentPulse : maxPulse;

      // Check for Hypokinetic Pulse (B): Weak amplitude, smaller peaks
      if (currentPulse > 50) {
        hypokineticPulse = false;
      }

      // Check for Hyperkinetic Pulse (C): Bounding amplitude, sharp peaks
      if (currentPulse < 100) {
        hyperkineticPulse = false;
      }

      // Check for Pulsus Alternans (E): Alternating strong and weak pulses
      if ((currentPulse > previousPulse && previousPulse < currentPulse) ||
          (currentPulse < previousPulse && previousPulse > currentPulse)) {
        pulsusAlternans = true;
      }

      // Check for Bigeminal Pulse (D): Pairs of beats with a pause after each pair
      if (bigeminalPulse == false && (currentPulse - previousPulse).abs() < 5 && (previousPulse - currentPulse).abs() > 10) {
        bigeminalPulse = true;
      }

      // Check for Waterhammer Pulse (F): Sharp, rapid rise followed by a sudden drop
      if (previousPulse - currentPulse > 20 && currentPulse - previousPulse > 20) {
        waterhammerPulse = true;
      }

      // Check for Pulsus Bisferiens (G): Two peaks per pulse cycle, a double bump
      if (firstPhase && currentPulse > previousPulse) {
        pulseReturnedToNormal = true;
      } else if (pulseReturnedToNormal && currentPulse < previousPulse) {
        pulsusBisferiens = true;
      }

      previousPulse = currentPulse;
    }

    if (pulsusBisferiens) {
      setState((){
        pulsePatternMessage = "Pulsus Bisferiens pattern detected.";
        suggestion = "Suggestion: This may be indicative of aortic regurgitation or other cardiac conditions. Consulting a healthcare provider for a comprehensive assessment and treatment plan is recommended.";
      });
    } else if (waterhammerPulse) {
      setState((){
        pulsePatternMessage = "Waterhammer pulse pattern detected.";
        suggestion = "Suggestion: This pattern is often associated with aortic regurgitation or other conditions affecting the aortic valve. A healthcare provider should evaluate this pattern to determine the underlying cause and appropriate management, which may include medication or surgical interventions.";
      });
    } else if (bigeminalPulse) {
      setState((){
        pulsePatternMessage = "Bigeminal pulse pattern detected.";
        suggestion = "Suggestion: This can be a sign of underlying heart rhythm issues, such as ventricular extrasystoles or other arrhythmias. A healthcare provider should assess this pattern to determine the appropriate treatment or management strategy.";
      });
    } else if (pulsusAlternans) {
      setState((){
        pulsePatternMessage = "Pulsus Alternans pattern detected.";
        suggestion = "Suggestion: This pattern can be indicative of left ventricular dysfunction or heart failure. It's essential to seek medical attention for a thorough evaluation and potential treatment, which might include medications or other interventions.";
      });
    } else if (hyperkineticPulse) {
      setState((){
         pulsePatternMessage = "Hyperkinetic pulse pattern detected.";
         suggestion = "Suggestion: This may indicate conditions such as fever, anemia, or hyperthyroidism. Consulting a healthcare provider to determine the underlying cause is crucial. Management might involve addressing the underlying condition or adjusting medications.";
      });
     
    } else if (hypokineticPulse) {
      setState((){
         pulsePatternMessage = "Hypokinetic pulse pattern detected.";
         suggestion = "Suggestion: This could suggest low cardiac output or heart failure. It's important to consult a healthcare provider for further evaluation. Lifestyle changes, medication adjustments, or treatments may be necessary based on the underlying cause.";
      });
    } else {
      setState((){
        pulsePatternMessage = "No specific pulse pattern detected.";
        suggestion = "Continue monitoring and consult with a doctor in the app if needed.";
      });
    }

    print(pulsePatternMessage); // Optionally print the detected pattern message
  }


  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize with today's date
    selectedDate = today;
    getAllPulseRecordsByToday();
  }

  DateTime? selectedDate;

  DateTime today = DateTime.now();

  // List of month names
  final List<String> monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  DateTime? startRange, endRange;

  String? dateRange;

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

      body: Container(
        decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301847), Color(0xFFC10214)
                ],
              )
          ),
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.all(10),
        child: RefreshIndicator(
          color: Colors.orange,
          onRefresh: ()async {
            // Simulate a time-consuming task
            await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
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
                          lastDate: today,
                          currentDate: today,
                          firstDate: DateTime(2000, 1, 1),
                          dayTextStyle: GoogleFonts.poppins(color: Colors.black),
                          monthTextStyle: GoogleFonts.poppins(color: Color(0xFF000000)),
                          yearTextStyle: GoogleFonts.poppins(color: Colors.black),
                          okButtonTextStyle: GoogleFonts.poppins(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
                          selectedMonthTextStyle: GoogleFonts.poppins(color: Colors.white),
                          selectedDayTextStyle: GoogleFonts.poppins(color: Colors.white),
                          selectedDayHighlightColor: Color(0xFFFF4081),
                          selectedYearTextStyle: GoogleFonts.poppins(color: Colors.white),
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
                          getPulseRecordsBySpecificDate(selectedDate!);
                        });
                        print("Selected Date: ${selectedDate.toString()}"); // Print the selected date
                        
                      }
                    },
                    child: Row(
                      children: [
                        Text("${selectedDate == today ? "Today" : "${selectedDate!.day.toString()} ${monthNames[selectedDate!.month - 1]} ${selectedDate!.year.toString()}"} ", style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0
                        ),),

                        Icon(Icons.arrow_drop_down_sharp, color: Colors.white),
                      ],
                    ),
                  ),
                ),
          
                SizedBox(height: 10),
          
                Container(
                  child: Row(
                    children: [
                      
                      Container(
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.sizeOf(context).width / 4,
                        width: MediaQuery.sizeOf(context).width / 4,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        child: Column(
                          children: [
                            Text("Average BPM", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0
                            ),),

                            Spacer(),

                            Text("${avg == null ? "-" : avg}", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22.0
                            ),),
                          ],
                        ),
                      ),
          
                      Spacer(),
          
                      Container(
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.sizeOf(context).width / 4,
                        width: MediaQuery.sizeOf(context).width / 4,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        child: Column(
                          children: [
                            Text("Minimum BPM", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0
                            ),),

                            Spacer(),

                            Text("${min == null ? "-" : min}", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22.0
                            ),),
                          ],
                        ),
                      ),
          
                      Spacer(),
                      
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        height: MediaQuery.sizeOf(context).width / 4,
                        width: MediaQuery.sizeOf(context).width / 4,
                        
                        child: Column(
                          children: [
                            Text("Maximum BPM", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0
                            ),),

                            Spacer(),

                            Text("${max == null ? "-" : max}", style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22.0
                            ),),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
          
                SizedBox(height: 20),
          
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      direction: vertical ? Axis.vertical : Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < _selectedDays.length; i++) {
                            _selectedDays[i] = i == index;
                          }
                          if (_selectedDays[0]) {
                            getPulseRecordsBySpecificDate(selectedDate!);
                          } else if (_selectedDays[1]) {
                            getPulseRecordsForWeek(selectedDate!);
                          } else if (_selectedDays[2]) {
                            getPulseRecordsForMonth(selectedDate!);
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderColor: Color(0xFFFFFFFF),
                      selectedColor: Colors.white,
                      selectedBorderColor: Color(0xFFFFFFFF),
                      fillColor:  Color(0xFFFF4081),
                      color: Colors.black,
                      constraints: BoxConstraints(
                        minHeight: 40.0,
                        minWidth: MediaQuery.sizeOf(context).width / 3.5,
                      ),
                      isSelected: _selectedDays,
                      children: [
                        Text('Day', style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15
                        ),),
                        Text('Week', style: GoogleFonts.poppins(
                        color: Colors.white,
                          fontSize: 15.0
                        ),),
                        Text('Month', style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.0
                        ),),
                      ],
                    ),
                  ],
                ),
          
                SizedBox(height: 40),
          
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SfCartesianChart(
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(
                      // For days view
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0),
                      /* title: AxisTitle(
                        text: 'Day',
                        textStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0),
                      ), */
                    ),
                
                    primaryYAxis: NumericAxis(
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                      /* title: AxisTitle(
                        text: 'Celsius', // Set the label for X axis
                        textStyle:  GoogleFonts.poppins(
                          color: Colors.black, fontWeight: FontWeight.w600,
                          fontSize: 15.0
                        ),
                      ), */
                    ),
                
                
                    title: ChartTitle(
                      text: '${graphTitle}',
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                    ),
                
                    series: <CartesianSeries>[
                
                      /*  
                        ColumnSeries: Displays data as vertical columns, with height representing the data value.
                        BarSeries: Similar to ColumnSeries, but the columns are horizontal.
                        AreaSeries: Displays data as a filled area, with the area under the curve filled with color.
                        SplineSeries: Similar to LineSeries, but the curve is smoothed out.
                        ScatterSeries: Represents individual data points as symbols without connecting them.
                        BubbleSeries: Represents data points as bubbles, with the size of the bubble representing the data value.
                        PieSeries: Displays data as slices of a pie, with each slice representing a category and its size representing the data value.
                        DoughnutSeries: Similar to PieSeries, but with a hole in the center. 
                      */
                
                      pulsesData.length > 1
                      // Temperature Series
                      ? SplineSeries<GraphData, String>(
                        color: Color(0xFFFF4081),
                        dataSource: pulsesData,
                        xValueMapper: (GraphData value, _) => value.day,
                        yValueMapper: (GraphData value, _) => value.value,
                        enableTooltip: true,
                        name: 'Heart rate (BPM)', // Name of the series
                        /* dataLabelSettings: DataLabelSettings(
                          isVisible: true, textStyle:  GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.0
                        ),) */
                      )
                      
                      : ColumnSeries<GraphData, String>(
                        color: Color(0xFFFF4081),
                        dataSource: pulsesData,
                        xValueMapper: (GraphData value, _) => value.day,
                        yValueMapper: (GraphData value, _) => value.value,
                        enableTooltip: true,
                        name: 'Heart rate (BPM)', // Name of the series
                        /* dataLabelSettings: DataLabelSettings(
                          isVisible: true, textStyle:  GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.0
                        ),) */
                      ),
                
                
                    ],
                    // Enable legend
                
                    // Custom legend position
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.auto, // Adjust the position here
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10.0
                      ),
                    ),
                
                    // Enable zooming and panning
                    zoomPanBehavior: ZoomPanBehavior(
                      enableSelectionZooming: true,
                      enableMouseWheelZooming: true,
                      enablePanning: true,
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                    ),
                
                    // Add tooltip
                    tooltipBehavior: TooltipBehavior(
                      textStyle:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 8.0
                      ),
                      enable: true,
                
                    ),
                
                
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text("${dateRange == null ? "" : dateRange}", style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.0,
                  ), textAlign: TextAlign.center),
                ),
                
          
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text("${pulsePatternMessage == null ? "" : pulsePatternMessage}", style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.0, fontWeight: FontWeight.w600,
                  ), textAlign: TextAlign.center),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 2.0),
                  child: Text("${suggestion == null ? "" : suggestion}", style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.0,
                  ), textAlign: TextAlign.justify),
                ),
          
          
                Container(
                  alignment: Alignment.center,
                    height: 200,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("View mode", style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 17.0
                          ),),
          
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the row's children
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
          
                            SizedBox(width: 5),
          
                            InkWell(
                              onTap: (){
                                getAllPulseRecordsByToday();
                                setState(() {
                                  graphTitle = "Today Pulse";
                                  dateRange = null;
                                  selectedDate = DateTime.now();
                                });
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.white,),
                                        
                                      Text("Today", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0
                                      ),),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            ),
                        
                        
                            InkWell(
                              onTap: () async{
                                 var date_result = await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config: CalendarDatePicker2WithActionButtonsConfig(
                                    controlsTextStyle:  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                                    selectedDayHighlightColor: Color(0xFFFF4081),
                                    weekdayLabelTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                                    lastMonthIcon: Icon(Icons.arrow_back_ios, color: Colors.black),
                                    nextMonthIcon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                                    firstDate: DateTime(2000, 1, 1),
                                    lastDate: today,
                                    currentDate: today,
                                    dayTextStyle: GoogleFonts.poppins(color: Colors.black),
                                    monthTextStyle: GoogleFonts.poppins(color: Color(0xFF000000)),
                                    yearTextStyle: GoogleFonts.poppins(color: Colors.black),
                                    okButtonTextStyle: GoogleFonts.poppins(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
                                    selectedMonthTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    selectedDayTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    selectedYearTextStyle: GoogleFonts.poppins(color: Colors.white),
                                    calendarType: CalendarDatePicker2Type.range,
                                    cancelButtonTextStyle:  GoogleFonts.poppins(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),

                                  ),
                                  dialogSize: const Size(325, 400),
                                  value: [startRange, endRange],
                                  borderRadius: BorderRadius.circular(15),
                                  
                                );

                                // If results are not null and contain at least one date, update the selected date
                                if (date_result != null) {
                                  setState(() {

                                    startRange = date_result.first; // Update selected date to the first (and only) selected date
                                    endRange = date_result.last;
                                    getPulseRecordsByDateRange(startRange!, endRange!);
                                    dateRange = "Date Selected: ${startRange!.day} ${monthNames[startRange!.month - 1]} ${startRange!.year} - ${endRange!.day} ${monthNames[endRange!.month - 1]} ${endRange!.year} ";
                                    graphTitle = "Pulse records between ${startRange!.day} ${monthNames[startRange!.month - 1]} ${startRange!.year} and ${endRange!.day} ${monthNames[endRange!.month - 1]} ${endRange!.year} ";
                                  });
                                  
                                  
                                }       
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  width:  MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_view_day_rounded, color: Colors.white,),
                                        
                                      Text("Select date range", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ), textAlign: TextAlign.center),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            ),
                        
                        
                            InkWell(
                              onTap: (){
                                getHighestPulseRecordsForRecentDays();
                                setState(() {
                                  graphTitle = "Highest pulse records for Recent 5 days";
                                });
                              }, 
                              child: Card(
                                elevation: 3,
                                child: Container(
                                  width:  MediaQuery.sizeOf(context).width / 4,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.data_exploration, color: Colors.white,),
                                        
                                      Text("Highest records in recent 5 days", style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ), textAlign: TextAlign.center),
                                        
                                        
                                    ],
                                  ),
                                ),
                              )
                            )
                            
                          ],
                        ),
                      ],
                    )
                  ),
          
          
                   SizedBox(height: 70),
                
              ],
            ),
          ),
        )
      )
    );
  }
}