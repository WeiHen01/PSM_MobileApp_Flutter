import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Contacts extends StatefulWidget {

  final int? id;
  const Contacts({super.key, this.id});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  Iterable<CallLogEntry>? _callLogs;

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    try {
      final Iterable<CallLogEntry> result = await CallLog.get();
      setState(() {
        _callLogs = result;
      });
    } catch (e) {
      print('Failed to fetch call logs: $e');
    }
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
                  itemCount: _callLogs?.length ?? 0,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 8); // Adjust the height as needed
                  },
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    final entry = _callLogs?.elementAt(index);
                    return Card(
                      child: ListTile(
                        title: Text(entry?.name ?? 'Unknown', style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black,
                          fontSize: 20.0
                        ),),
                        subtitle: Text(entry?.number ?? 'No number', style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15.0
                        ),),
                        trailing: Text(entry?.duration.toString() ?? '0', style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15.0
                        ),),
                        leading: Icon(Icons.people),
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