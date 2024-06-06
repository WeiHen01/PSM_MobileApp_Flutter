import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../../../Controller/MongoDBController.dart';
class EmergencyCall extends StatefulWidget {

  final int? id; 

  const EmergencyCall({super.key, this.id});

  @override
  State<EmergencyCall> createState() => _EmergencyCallState();
}

class _EmergencyCallState extends State<EmergencyCall> {

  final TextEditingController textfield = TextEditingController();

  onNumberTapped(number) {
    setState(() {
      textfield.text += number;
    });
  }

  onCancelText() {
    if (textfield.text.isNotEmpty) {
      var newvalue = textfield.text.substring(0, textfield.text.length - 1);
      setState(() {
        textfield.text = newvalue;
      });
    }
  }

  onClearText(){
    if (textfield.text.isNotEmpty) {
      setState(() {
        textfield.clear();
      });
    }
  }

  CallContact() async{
    if (textfield.text.isNotEmpty) {
      bool? res = await FlutterPhoneDirectCaller.callNumber(textfield.text);

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
          "TargetNumber": textfield.text,
          "CallingTimestamp" : now,
          "PatientID": widget.id
        };

        print(message);

        // Store the message in MongoDB
        var result = await db.insert("Emergency_Call", message);

        print(result);
        
    }
  }

  Widget inputField() {
    return Container(
      color: Colors.white,
      height: 50,
      alignment: Alignment.bottomCenter,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),
        controller: textfield,
        maxLength: 15,
        
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget gridView() { 
    return Container(
      padding: const EdgeInsets.only(top: 100),
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.7,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        children: [
          keyField("1", ""),
          keyField("2", "A B C"),
          keyField("3", "D E F"),
          keyField("4", "G H I"),
          keyField("5", "J K L"),
          keyField("6", "M N O"),
          keyField("7", "P Q R S"),
          keyField("8", "T U V"),
          keyField("9", "W X Y Z"),
          starField(),
          keyField("0", "+"),
          hashField(),
          blankField(),
          dialField(),
          backSpace()
        ],
      ),
    );
  }

  Widget keyField(numb, dsc) {
    return InkWell(
      onTap: () => onNumberTapped(numb),
      child: Container(
        
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              numb,
              style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            Text(
              dsc,
              style:
                  GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }

  Widget starField() {
    return InkWell(
      onTap: () => onNumberTapped("*"),
      child: Container(
        height: 20,
        width: 20,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(60)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              "*",
              style: GoogleFonts.poppins(fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget hashField() {
    return InkWell(
      onTap: () => onNumberTapped("#"),
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(60)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              "#",
              style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget backSpace() {
    if (textfield.text.isNotEmpty) {
      return InkWell(
        onTap: () => onCancelText(),
        onLongPress: () => onClearText(),
        child: Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.backspace_outlined,
                size: 30,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(height: 0);
    }
  }

  Widget dialField() {
    return GestureDetector(
      onTap: () => CallContact(),
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.green[500], borderRadius: BorderRadius.circular(60)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.phone,
              size: 40,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget blankField() {
    return InkWell(
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(60)),
      ),
    );
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

        title: Text("Emergency Call", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, color: Colors.white,
          fontSize: 20.0
        ),),
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(bottom: 80.0, top: 15, left: 8, right: 8),
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text("Make a call here", style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black,
                  fontSize: 20.0
                ),),

                SizedBox(height:20),

                
                SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Column(children: [inputField(), gridView()]),
                  ),
                ),



                
                
                  
                  
              ],
            ),
          ),
        ),
      )
    );
  }
}