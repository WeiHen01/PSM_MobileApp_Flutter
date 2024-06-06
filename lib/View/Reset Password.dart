import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../Controller/MongoDBController.dart';
//import '../Controller/Request Controller.dart';
import 'Login Menu.dart';

class ResetPassword extends StatefulWidget {
  final int? id;
  final String? username;
  final String? role;
  ResetPassword({Key? key, this.id, this.username, this.role});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController conPasswordCtrl = TextEditingController();

  bool _password = false;
  bool _confirmPass = false;

  void togglePassword()
  {
    setState(() {
      _password = !_password;
    });
  }

  void toggleconfirmPassword()
  {
    setState(() {
      _confirmPass = !_confirmPass;
    });
  }

  Future<void> resetPassword() async {
    
    if(passwordCtrl.text != conPasswordCtrl.text){
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "DIFFERENT PASSWORD INPUT DETECTED!",
          text: "Please make sure both input for new password and confirm new password are the same ",
        )
      );
    }
    else {
      if(widget.role == "Patient"){
        Map<String, dynamic> requestBody = {};

        requestBody["PatientPassword"] = passwordCtrl.text;

        MongoDatabase mongo = MongoDatabase();

        bool updateResult = await mongo.update("Patient", "PatientID", widget.id, requestBody);

        if(updateResult == true){
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "RESET PATIENT ACCOUNT DONE!",
              text: "Your password is reset successfully! You may go to login now.",
              onConfirm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMenu()),
                );
              },
            )
          );
        }
        else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "RESET PATIENT ACCOUNT FAILED!",
              text: "Your account is not updated! Please try again!",
            )
          );
        }
      }
      else {
        Map<String, dynamic> requestBody = {};

        requestBody["DoctorPassword"] = passwordCtrl.text;

        MongoDatabase mongo = MongoDatabase();

        bool updateResult = await mongo.update("Doctor", "DoctorID", widget.id, requestBody);

        if(updateResult == true){
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "RESET DOCTOR ACCOUNT DONE!",
              text: "Your password is reset successfully! You may go to login now.",
              onConfirm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMenu()),
                );
              },
            )
          );
        }
        else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "RESET DOCTOR ACCOUNT FAILED!",
              text: "Your account is not updated! Please try again!",
            )
          );
        }
      }
    }

    
  }

  /* Future<void> resetPassword() async {
    
    if(passwordCtrl.text != conPasswordCtrl.text){
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "DIFFERENT PASSWORD INPUT DETECTED!",
          text: "Please make sure both input for new password and confirm new password are the same ",
        )
      );
    }
    else {
      if(widget.role == "Patient"){
        Map<String, dynamic> requestBody = {};

        requestBody["PatientPassword"] = passwordCtrl.text;

        WebRequestController req = WebRequestController(
          path: "patient/update/id/${widget.id}"
        );

        req.setBody(requestBody);
        await req.put();

        print("Update status: ${req.status()}");

        print(req.result());

        if(req.status() == 200){
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "RESET PATIENT ACCOUNT DONE!",
              text: "Your password is reset successfully! You may go to login now.",
              onConfirm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMenu()),
                );
              },
            )
          );
        }
        else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "RESET PATIENT ACCOUNT FAILED!",
              text: "Your account is not updated! Please try again!",
            )
          );
        }
      }
      else {
        Map<String, dynamic> requestBody = {};

        requestBody["DoctorPassword"] = passwordCtrl.text;

        WebRequestController req = WebRequestController(
          path: "doctor/update/id/${widget.id}"
        );

        req.setBody(requestBody);
        await req.put();

        print("Update status: ${req.status()}");

        print(req.result());

        if(req.status() == 200){
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "RESET DOCTOR ACCOUNT DONE!",
              text: "Your password is reset successfully! You may go to login now.",
              onConfirm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMenu()),
                );
              },
            )
          );
        }
        else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "RESET DOCTOR ACCOUNT FAILED!",
              text: "Your account is not updated! Please try again!",
            )
          );
        }
      }
    }

    
  } */
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF301847), Color(0xFFC10214)
            ],
          )
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("images/Reset_password.png", height: 450),
          
                Text("RESET ${widget.role?.toUpperCase()} PASSWORD",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 30, color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xFF545454),
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                        ),
                      ],
                    )
                ),
          
                SizedBox(height: 20),
          
          
          
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text("Welcome back, ${(widget.role == "Patient") ? 'Patient ${widget.username}!' : 'Doctor ${widget.username}!'} Please enter new input for resetting the password!",
                          style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.white,
                          ), textAlign: TextAlign.justify,
                      ),
          
                      SizedBox(height: 20),
          
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                            ],
                          ),
            
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                      
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          controller: passwordCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            //errorText: 'Please enter a valid value',
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Enter your password",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                              ),
                              labelText: "Enter your password",
                              labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                              ),
                              suffixIcon: Tooltip(
                                message: _password ? 'Hide Password' : 'Show Password',
                                child: IconButton(
                                  onPressed: togglePassword,
                                  icon: Icon(_password
                                      ? Icons.visibility_off
                                      : Icons.visibility, color: Colors.white,),
                                ),
                              ),
                              errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                                color: Colors.red,
                              ),
                            
                          ),
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.white
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF301847), Color(0xFFC10214)
                            ],
                          ),
            
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                      
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0)
                          )
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter confirm password';
                            }
                            return null;
                          },
                          controller: conPasswordCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            //errorText: 'Please enter a valid value',
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: Tooltip(
                                message: _confirmPass ? 'Hide Password' : 'Show Password',
                                child: IconButton(
                                  onPressed: toggleconfirmPassword,
                                  icon: Icon(_confirmPass
                                      ? Icons.visibility_off
                                      : Icons.visibility, color: Colors.white,),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Confirm your password",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                              ),
                              labelText: "Confirm your password",
                              labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                              ),
                              errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                                color: Colors.red,
                              ),
                            
                          ),
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.white
                          ),
                        ),
                      ),
          
          
                      SizedBox(height: 30),
          
                      /**
                      * The register button
                      */
                      GestureDetector(
                        onTap: (){
                          // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing Data')),
                              );

                              resetPassword();
                            }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                                    
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
          
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF301847), Color(0xFFC10214)
                                ]
                              ),
                              width: 4,
                            ),
          
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1f1f1f), // Shadow color
                                offset: Offset(0, 2), // Offset of the shadow
                                blurRadius: 4, // Spread of the shadow
                                spreadRadius: 0, // Spread radius of the shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: GradientText(
                                'Request reset password',
                                style: GoogleFonts.poppins(
                                    fontSize: 20.0, fontWeight: FontWeight.bold
                                ),
                                colors: [
                                    Color(0xFF301847), Color(0xFFC10214)
                                ],
                            ),
                          ),
                        ),
                      ),
          
                    ],
                  ),
          
                )
              ],
            ),
          ),
        )
      )
    );
  }
}