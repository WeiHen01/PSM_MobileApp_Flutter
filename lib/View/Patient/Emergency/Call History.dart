import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Controller/MongoDBController.dart';
import '../../../Model/Emergency.dart';

class CallHistory extends StatefulWidget {

  final int? id;
  const CallHistory({super.key, this.id});

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {

  //Iterable<CallLogEntry>? _callLogs;

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  late List<Emergency> calls = [];

  Future<void> _fetchCallLogs() async {
    try {
      //final Iterable<CallLogEntry> result = await CallLog.get();
      // Assuming 'MongoDatabase' instance is accessible here
      var emergencyCall = await MongoDatabase().getByQuery("Emergency_Call", 
        {
          "PatientID" : widget.id
        }
      );
      print("All Call: $emergencyCall");
      if(emergencyCall.isNotEmpty){
        setState((){
          calls = emergencyCall.map((json) => Emergency.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Failed to fetch call logs: $e');
    }
  }

  CallContact(String number) async{
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);

    // save the emergency contact
    MongoDatabase db = MongoDatabase();

    Map<String, dynamic> query = {
      "PatientID": {"\$exists": true} // Check if ChatID exists
    };

    // Count the total number of documents in the "Chat" collection
    var lists = await db.getCertainInfo("Emergency_Call");

    int total = lists.length;

    // Increment the new chat ID by 1
    int newCallID = total + 1;

    DateTime now = DateTime.now();

    // Construct the message document
    Map<String, dynamic> message = {
      "CallingID": newCallID,
      "TargetNumber": number,
      "CallingTimestamp" : now,
      "PatientID": widget.id
    };

    print(message);

    // Store the message in MongoDB
    var result = await db.insert("Emergency_Call", message);

    print(result);
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

        title: Text("Contacts", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          await Future.delayed(Duration(seconds: 1));
          _fetchCallLogs();
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recent", style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.black,
                fontSize: 20.0
              ),),

              SizedBox(height: 15.0,),
        
              Expanded(
                child: ListView.separated(
                  itemCount: calls.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 8); // Adjust the height as needed
                  },
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    final entry = calls.elementAt(index);
                    return Card(
                      child: ListTile(
                        title: Text(entry.targetNumber, style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black,
                          fontSize: 20.0
                        ),),
                        subtitle: Text("${entry.callDateTime}", style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12.0
                        ),),
                        leading: Icon(Icons.call),
                        trailing: IconButton(onPressed: (){
                          CallContact(entry.targetNumber);
                        }, icon: Icon(Icons.phone),),
                      ),
                    );
                  }
                ),
              )
            ],
          ),
        )
      )
    );
  }
}