/* import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

//import '../../../Controller/Request Controller.dart';
//import '../../../Model/Chat.dart';
import '../../../Model/Patient.dart';
import '../../../Controller/MongoDBController.dart';
import 'Chatroom.dart';

class DoctorChat extends StatefulWidget {

  final int? id;
  const DoctorChat({Key? key, this.id});

  @override
  State<DoctorChat> createState() => _DoctorChatState();
}

class _DoctorChatState extends State<DoctorChat> {

  TextEditingController searchCtrl = TextEditingController();

  late List<Patient> allPatients = [];
  Future<void> getAllPatients () async {
    try {
      // Assuming 'MongoDatabase' instance is accessible here
      var patient = await MongoDatabase().getCertainInfo("Patient");
      print("All: $patient");
      
      if(patient.isNotEmpty){
        setState(() {
          allPatients = patient.map((json) => Patient.fromJson(json)).toList();
        });
      }

    } catch (e, stackTrace) {
      print('Error fetching other patients : $e');
      print(stackTrace);
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  /* Future<void> getAllPatients () async {
    WebRequestController req = WebRequestController(
      path: "patient"
    );

    await req.get();

    try{
      if (req.status() == 200) {
        List<dynamic> data = req.result();

        setState(() {
          allPatients = data.map((json) => Patient.fromJson(json)).toList();
        });
        
      }
    }catch (e) {
      print('Error fetching patients : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  
  late List<Map<String, dynamic>> lastMessages = []; // List to store the last message for each patient
  Future<List<Map<String, dynamic>>>  getLastMessagesForPatients(List<Patient> patients) async {
    List<Map<String, dynamic>> messages = [];
    for (var patient in patients) {
      try {
        print("Patients: ${patient.patientID}");
        var chats = await MongoDatabase().getByQuery("Chat", {
          "\$or": [
            {"PatientID": "P-${patient.patientID}", "ReceiverID": "D-${widget.id}"},
            {"PatientID": "D-${widget.id}", "ReceiverID": "P-${patient.patientID}"}
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
        print('Error fetching last message for patient ${patient.patientID}: $e');
        // Handle the exception as needed
        messages.add({
          'message': 'Error fetching message',
          'timestamp': ''
        });
      }
    }
    return messages;
  }

  Future<void> getAllPatientsWithLastMessages() async {
    try {
      var patients = await MongoDatabase().getCertainInfo("Patient");
      print("All: $patients");

      if (patients.isNotEmpty) {
        List<Patient> fetchedPatients = patients.map((json) => Patient.fromJson(json)).toList();
        List<Map<String, dynamic>> messages = await getLastMessagesForPatients(fetchedPatients);
        setState(() {
          allPatients = fetchedPatients;
          lastMessages = messages;
        });
      }
    } catch (e) {
      print('Error fetching other patients: $e');
      // Handle the exception as needed
    }
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
    if (hour == 0 || hour == 24) {
      hour += 12; // 12 AM
    } else if (hour > 12) {
      hour -= 12; // Convert to 12-hour format
    } else {
      hour = hour;
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
    getAllPatients();
    getAllPatientsWithLastMessages();
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


        title: Text("Chat with Patients", style: GoogleFonts.poppins(
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
          getAllPatients();
        },
        child: Container(
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
                  onChanged: (value) {
                  // If the query is empty, reload all users
                  if (value.isEmpty) {
                    getAllPatients();
                    getAllPatientsWithLastMessages();
                  } else {
                    // Filter otherUsers based on the entered query
                    setState(() {
                      allPatients = allPatients.where((user) =>
                        user.patientName.toLowerCase().contains(value.toLowerCase())
                      ).toList();
                    });
                  }
                  },
                ),
            
                const SizedBox(height: 10.0,),
            
                /**
                 * List 1
                 */
                allPatients != null
                ? Container(
                  height: MediaQuery.of(context).size.height * 0.26,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: allPatients.length,
                          scrollDirection: Axis.horizontal,
                          itemExtent: 120,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final user = allPatients[index];
                            return Container(
                              
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  
                                  InkWell(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => DoctorChatRoom(patientID: user.patientID, doctorID: widget.id,)
                                        )
                                      );
                                    },
                                    child: Card(
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.pink,
                                                
                                              ),
                                            ),
                                        
                                            SizedBox(height: 5),
                                                              
                                            GradientText(allPatients.isNotEmpty ? user.patientName :"", 
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15, 
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
                          }
                        ),
                      ),
                    ],
                  ),
                )
                : Center(child: CircularProgressIndicator()),// Add some space between the lists
            
                SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Chats", style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.black,
                      fontSize: 20.0
                    ),),
                  ],
                ),
            
                /**
                 * List 2
                 */
                allPatients != null
                ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allPatients.length,
                      itemBuilder: (context, index) {
                       
                        final user = allPatients[index];

                        print("User: ${user.patientID}");

                        //getChatsBubbles(user.patientID);

                        // Inside the ListView.builder where you display patient cards
                        final lastMessageData = lastMessages.isNotEmpty ? lastMessages[index] : {'message': '', 'timestamp': ''};


                        print("Latest msg: ${lastMessageData['message']}");
                        print("Latest time: ${lastMessageData['timestamp']}");

                        //Split the timestamp into date and time components
                        List<String> components = lastMessageData['timestamp'].split(' ');

                        // Extract date and time components
                        print(components);

                        String date = components.first; 

                         // Get the current date
                        DateTime currentDate = DateTime.now();
                        DateTime? localDateTime;

                        // Initialize localDateTime based on the extracted date string
                        try {
                          localDateTime = DateTime.parse(date);
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
                            formattedDate = "${localDateTime.year}-${localDateTime.month.toString().padLeft(2, '0')}-${localDateTime.day.toString().padLeft(2, '0')}";
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

                        if(lastMessageData.isNotEmpty){
                          hour = items.length > 1 ? int.parse(items.first) : '';
                          minute = items.length > 1 ? items.elementAt(1) : '';

                          print("$hour: $minute");

                          // Determine the meridiem (AM or PM)
                          if(hour != ""){
                            meridiem = hour < 12 ? 'AM' : 'PM';
                            // Convert the hour to 12-hour format
                            if (hour > 12) {
                              hour -= 12; // Convert to 12-hour format
                            }
                            else if(hour == 0){
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
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => DoctorChatRoom(patientID: user.patientID, doctorID: widget.id,)
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
                                        color: Colors.pink,
                                        
                                      ),
                                    ),

                                    title: GradientText(allPatients.isNotEmpty ? user.patientName :"", 
                                      style: GoogleFonts.poppins(
                                          fontSize: 18, fontWeight: FontWeight.w500,
                                      ),
                                      colors: [
                                          Color(0xFF301847), Color(0xFFC10214)
                                      ],
                                    ),

                                    subtitle: Text(lastMessageData['message'],
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 15.0
                                      ),
                                    ),

                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(formattedDate,
                                          style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 15.0
                                        ),),

                                        Text(formattedTime,
                                          style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 15.0
                                        ),),
                                      ],
                                    ),
                                  
                                      
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                )
                : Center(child: CircularProgressIndicator()),// Add some space between the lists
                
            
            
            
                
              ],
            ),
          ),
        ),
      ),
    );
  }
} */