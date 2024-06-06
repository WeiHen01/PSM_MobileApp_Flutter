import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../../Controller/OneSignal Controller.dart';
// import '../../../Controller/Request Controller.dart';
import '../../../Model/Chat.dart';
import '../../../Controller/MongoDBController.dart';

class DoctorChatRoom extends StatefulWidget {

  final int? patientID, doctorID;
  const DoctorChatRoom({Key? key, this.patientID, this.doctorID});

  @override
  State<DoctorChatRoom> createState() => _DoctorChatRoomState();
}

class _DoctorChatRoomState extends State<DoctorChatRoom> {

  String name = "", email = "";
  Future<void> getChatTarget () async {
    
    print("Self: ${widget.doctorID}, Other: ${widget.patientID}");
    MongoDatabase mongo = MongoDatabase();

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientID'] == widget.patientID) {
        setState((){
          patientData = user;
          print("Target: ${patientData}");
          name = patientData["PatientName"];
          email = patientData["PatientEmail"];
        });
        break;
      }
    }

    fetchProfileImage();

  }

  /* Future<void> getChatTarget () async {
    WebRequestController req = WebRequestController(
      path: "patient/findPatient/${widget.patientID}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["PatientName"];
          email = data["PatientEmail"];
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  String OwnName = "";
  Future<void> getSelfProfile () async {
    print("Self: ${widget.doctorID}, Other: ${widget.patientID}");
    MongoDatabase mongo = MongoDatabase();

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Doctor");
    var doctorData;
    for (var user in userList) {
      if (user['DoctorID'] == widget.doctorID) {
        setState((){
          doctorData = user;
          print("Self: ${doctorData}");
          OwnName = doctorData["DoctorName"];
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
        'http://$server:8000/api/patient/profileImage/${widget.patientID}')
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

  /* Future<void> getSelfProfile () async {
    WebRequestController req = WebRequestController(
      path: "doctor/findDoctor/${widget.doctorID}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          OwnName = data["PatientName"];
        });
        
      }
    }catch (e) {
      print('Error fetching own profile : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  late List<Chat> wifdoctorChats = [];

  Future<void> getChatsBubbles () async {
    try {
      // Construct the query to filter chats between P-2 and D-1
      Map<String, dynamic> query = {
        "\$or": [
          {"PatientID": "P-${widget.patientID}", "ReceiverID": "D-${widget.doctorID}"},
          {"PatientID": "D-${widget.doctorID}", "ReceiverID": "P-${widget.patientID}"}
        ]
      };

      // Retrieve chat documents that match the query
      var chats = await MongoDatabase().getByQuery("Chat", query);

      print("Chat: $chats");

      // Update the state variable with the retrieved chat list
      setState(() {
        // Assuming Chat is the type of your chat documents
        wifdoctorChats = chats.map((chat) => Chat.fromJson(chat)).toList();
      });
      
    } catch (e, stackTrace) {
      print('Error fetching chats abc : $e\nStack Trace: $stackTrace');
      // Handle the exception as needed
    }
  }

  /* Future<void> getChatsBubbles () async {
    WebRequestController req = WebRequestController(
      path: "chat/findChatBetween/P-${widget.patientID}/D-${widget.doctorID}"
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

   /**
   * Send message
   *////
  Future sendMessage() async{

    try {
      DateTime now = DateTime.now();
      MongoDatabase db = MongoDatabase();

      Map<String, dynamic> query = {
        "ChatID": {"\$exists": true} // Check if ChatID exists
      };

      
      
       // Count the total number of documents in the "Chat" collection
      var lists = await db.getCertainInfo("Chat");

      int total = lists.length;

      // Increment the new chat ID by 1
      int newChatID = total + 1;

      // Construct the message document
      Map<String, dynamic> message = {
        "ChatID": newChatID,
        "ChatMessage": msgCtrl.text,
        "ChatDateTime": now.toString(),
        "ChatStatus": 'Unseen',
        "ReceiverID": "P-" + widget.patientID.toString(),
        "PatientID": "D-" + widget.doctorID.toString(),
      };

      print(message);

      // Store the message in MongoDB
      await db.insert("Chat", message);

      

      /**
       * Setup the target for the message to be sent
       */
      List<String> sendTo  = [];
      var targetID = "P-" + widget.patientID.toString();
      sendTo.add(targetID);

      OneSignalController onesignal = OneSignalController();
      onesignal.SendNotification(OwnName, msgCtrl.text, sendTo);
      getChatsBubbles();

      // Clear message input field
      setState(() {
        msgCtrl.clear();
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /**
   * Send message
   *////
  /* Future sendMessage() async{

    /**
       * save the data registered to database
       */
      WebRequestController req = WebRequestController
        (path: "chat/createChat");

      DateTime now = DateTime.now();

      

      req.setBody(
        {
          "ChatMessage": msgCtrl.text,
          "ChatDateTime": now.toString(),
          "ChatStatus": 'Unseen',
          "ReceiverID": "P-" + widget.patientID.toString(),
          "PatientID": "D-" + widget.doctorID.toString(),
        }
      );

      await req.post();

      print(req.result());

      if (req.result() != null) {

        /**
         * Setup the target for the message to be sent
         */
        List<String> sendTo  = [];
        var targetID = "P-" + widget.patientID.toString();
        sendTo.add(targetID);

        OneSignalController onesignal = OneSignalController();
        onesignal.SendNotification(OwnName, msgCtrl.text, sendTo);
        getChatsBubbles();
      }

      setState(() {
        msgCtrl.clear();
      });
    
  } */

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController msgCtrl = TextEditingController();

  final ScrollController _chatScroller  = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatTarget();
    getChatsBubbles();
    getSelfProfile();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _chatScroller.animateTo(
          _chatScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });
  }

  @override
  void dispose() {
    _chatScroller.dispose(); // Dispose ScrollController
    super.dispose();
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


        backgroundColor: Color(0xFFFF4081),
        title: Row(
          children: [
            
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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

            const SizedBox(width: 8),

            Text(name, style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
            
          ],
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),


      ),

      body:  wifdoctorChats != null
      ? Container(
        padding: const EdgeInsets.all(8),
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
             const Color(0xFF301847), 
             const Color(0xFFC10214).withOpacity(0.8)
            ],
          ),
          backgroundBlendMode: BlendMode.multiply,
        ),
        child: Column(
          children: [

            Expanded(
              child: Builder(
                builder: (context) {
                  SchedulerBinding.instance?.addPostFrameCallback((_) {
                    _chatScroller.animateTo(
                        _chatScroller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.fastOutSlowIn);
                  });
              
                  return RefreshIndicator(
                    color: Colors.orange,
                    edgeOffset: 50,
                    onRefresh: ()async {
                      // Simulate a time-consuming task
                      await Future.delayed(Duration(seconds: 1));
                      getChatTarget();
                      getChatsBubbles();
                      getSelfProfile();
                    },
                    child: ListView.builder(
                      controller: _chatScroller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: wifdoctorChats.length,
                      itemBuilder: (context, index) {
                        final chat = wifdoctorChats[index];
                    
                        // Convert UTC DateTime to local DateTime
                        DateTime? localDateTime = chat.chatDateTime;

                        // Get the current date
                        DateTime currentDate = DateTime.now();

                        // Extract hour and minute from the DateTime object
                        int hour = chat.chatDateTime?.hour ?? 0;
                        int minute = chat.chatDateTime?.minute ?? 0;

                        // Determine if it's AM or PM
                        String period = (hour < 12) ? 'AM' : 'PM';

                        // Convert hour to 12-hour format
                        if (hour > 12) {
                          hour -= 12;
                        } else if (hour == 0) {
                          hour = 12;
                        }

                        // Format minute to two digits
                        String formattedMinute = (minute < 10) ? '0$minute' : '$minute';

                        bool showDate = false;

                        if (index == 0) {
                          showDate = true;
                        } else {
                          DateTime? previousMessageDateTime = wifdoctorChats[index - 1].chatDateTime;
                          DateTime? previousMessageLocalDateTime = previousMessageDateTime?.toLocal();

                          showDate = localDateTime?.year != previousMessageLocalDateTime?.year ||
                          localDateTime?.month != previousMessageLocalDateTime?.month ||
                          localDateTime?.day != previousMessageLocalDateTime?.day;
                        }

                        String? formattedDate;
                        if (showDate) {
                          // Check if the date is today
                          if (localDateTime?.year == currentDate.year &&
                              localDateTime?.month == currentDate.month &&
                              localDateTime?.day == currentDate.day) {
                            formattedDate = 'Today';
                          } 
                          // Check if the date is yesterday
                          else if (localDateTime?.year == currentDate.year &&
                              localDateTime?.month == currentDate.month &&
                              localDateTime?.day == currentDate.day - 1) {
                            formattedDate = 'Yesterday';
                          } 
                          // Otherwise, display the date
                          else {
                            formattedDate = "${localDateTime?.year}-${localDateTime?.month.toString().padLeft(2, '0')}-${localDateTime?.day.toString().padLeft(2, '0')}";
                          }
                        }

                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                    
                              // Show the date if it's different from the date of the previous message
                              if (showDate)
                                Center(
                                  child: Container(
                                    color: Colors.pink.shade300.withOpacity(0.5),
                                    width: 150,
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        formattedDate!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              /**
                               * Patient Own Chat
                               */
                              Visibility(
                                visible: (chat.patient == "D-${widget.doctorID}") ? true : false,
                                child: Card(
                                  margin: (chat.patient == "D-${widget.doctorID}")
                                        ? EdgeInsets.only(left: MediaQuery.of(context).size.width / 5, top: 10, bottom: 10)
                                        : EdgeInsets.zero,
                                  child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (chat.patient == "D-${widget.doctorID}")
                                          ? Colors.white : Color(0xFFFF7F50),
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("You", style: GoogleFonts.poppins(
                                                  fontSize: 16, fontWeight: FontWeight.bold
                                            ),),
                    
                                            Spacer(),
                    
                                            Text('$hour:$formattedMinute $period', style: GoogleFonts.poppins(
                                                  fontSize: 16, fontWeight: FontWeight.bold
                                            ),),
                                          ],
                                        ),
                                
                                        Text(chat.chatMessage, style: GoogleFonts.poppins(
                                              fontSize: 16,
                                        ), softWrap: true, textAlign: TextAlign.justify,),
                                
                                        
                                      ],
                                    )
                                  ),
                                ),
                              ),
                                
                              
                              /**
                               * Chat from patient
                               */
                              Visibility(
                                visible: (chat.patient != "D-${widget.doctorID}") ? true : false,
                                child: Card(
                                  margin: (chat.patient != "D-${widget.doctorID}")
                                        ? EdgeInsets.only(right: MediaQuery.of(context).size.width / 5, top:10, bottom: 10)
                                        : EdgeInsets.zero,
                                  child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (chat.patient != "D-${widget.doctorID}")
                                          ?  Color(0xFFFF7F50) : Colors.white,
                                    ),
                                    
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name, style: GoogleFonts.poppins(
                                                  fontSize: 16, fontWeight: FontWeight.bold
                                            ),),
                    
                                            Spacer(),
                    
                                            Text('$hour:$formattedMinute $period', style: GoogleFonts.poppins(
                                                  fontSize: 16, fontWeight: FontWeight.bold
                                            ),),
                                          ],
                                        ),
                                
                                        
                                
                                        Text(chat.chatMessage, style: GoogleFonts.poppins(
                                              fontSize: 16, 
                                        ),),
                                
                                      
                                      ],
                                    )
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                        );
                      }
                    ),
                  );
                }
              ),
            ),

            Spacer(),
            
            const Divider(
              color: Colors.white,
            ),
            
            Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  
                  Expanded(
                    child: TextFormField(
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Empty message to be sent';
                        }
                        return null;
                      },
                      controller: msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                        prefixIcon: const Icon(Icons.message, color: Colors.white,),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                          color: Colors.red,
                        ),
                      ),
                      
                      style: GoogleFonts.poppins(
                        color: Colors.white
                      ),
                    ),
                  ),
              
                  IconButton(
                    onPressed: (){
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        sendMessage();
                      }
                      
                    },
                    icon: const Icon(Icons.send, color: Colors.white,)
                  )
                ],
              ),
            )

            

            
          ],
        )

      )
      : Center(child: CircularProgressIndicator(),),

    );
  }
}