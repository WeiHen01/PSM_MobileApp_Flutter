import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Controller/MongoDBController.dart';

class DoctorAboutMe extends StatefulWidget {
  final int? id;
  DoctorAboutMe({Key? key, this.id});

  @override
  State<DoctorAboutMe> createState() => _DoctorAboutMeState();
}

class _DoctorAboutMeState extends State<DoctorAboutMe> {

  TextEditingController specializeCtrl = TextEditingController();

  Future<void> getProfile () async {
    
    MongoDatabase mongo = MongoDatabase();

    await mongo.getCertainInfo("Doctor");

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Doctor");
    var doctorData;
    for (var user in userList) {
      if (user['DoctorID'] == widget.id) {
        setState((){
          doctorData = user;
          print(doctorData["DoctorSpecialize"]);
          specializeCtrl.text = doctorData["DoctorSpecialize"];
        });
        break;
      }
    }

  }

  Future<void> updateAccount() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (specializeCtrl.text != '' && specializeCtrl.text.isNotEmpty) {
      requestBody["DoctorSpecialize"] = specializeCtrl.text;
    }

    MongoDatabase mongo = MongoDatabase();

    bool updateResult = await mongo.update("Doctor", "DoctorID", widget.id, requestBody);

    
    if(updateResult) {
      await mongo.updateLastUpdateDateTime("Doctor", "DoctorID", widget.id, DateTime.now().toLocal());
      
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "UPDATE SUCCESSFUL",
          text: "Your specialize is updated successfully!",
        ),
      );
    }
    else
    {
     ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "UPDATE FAILURE",
          text: "Failed to update your specialize!",
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("About Me", style: GoogleFonts.poppins(
            fontSize: 20.0, color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(25),
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100),
          
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Write about your specialize:", style: GoogleFonts.poppins(
                        fontSize: 15.0, color: Colors.black,
                      )
                    ),

                    SizedBox(height: 10),
          
                    // Add TextFormFields and ElevatedButton here.
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Specialize',
                        hintStyle: GoogleFonts.poppins(),
                        prefixIcon: Icon(Icons.description),
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        counterStyle: GoogleFonts.poppins(
                          fontSize: 15.0, color: Colors.black,
                        )
                      ),
                      controller: specializeCtrl,
                      maxLength: 1000,
                      maxLines: 15,
                      style: GoogleFonts.poppins(
                          fontSize: 15
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        updateAccount();
                      },
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF301847), Color(0xFFC10214)
                              ],
                            ),
                        
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Save", style: GoogleFonts.poppins(
                                  fontSize: 16.0, color: Colors.white,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              ),
          
          
            ],
          ),
        )
        
      ),
    );
  }
}