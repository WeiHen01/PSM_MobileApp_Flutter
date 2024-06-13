import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Controller/MongoDBController.dart';
import '../Forget Password.dart';
import '../Login Menu.dart';
import '../Register Menu.dart';
import 'Google Login.dart';
import 'Home.dart';

class PatientLogin extends StatefulWidget {

  final Socket? socket;

  const PatientLogin({super.key, this.socket});

  @override
  State<PatientLogin> createState() => _PatientLoginState();
}





class _PatientLoginState extends State<PatientLogin> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  /// 1. _password -> for Show/Hide password
  bool _password = false;

  /// This is the function to show and hide password
  void togglePassword()
  {
    setState(() {
      _password = !_password;
    });
  }

  MongoDatabase mongo = MongoDatabase();
    

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    openDatabase("Patient");
  }

  Future<void> openDatabase(String collection) async {
    try {
      await mongo.open(collection);
      // Perform any other initialization after opening the database
    } catch (e) {
      // Handle any errors
      print(e.toString());
    }
  }

  Future login() async{
    
    // Replace these lines with your MongoDB connection details
    MongoDatabase mongo = MongoDatabase();
    await mongo.getCertainInfo('Patient');

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientEmail'] == emailCtrl.text && user['PatientPassword'] == passwordCtrl.text) {
        setState((){
          patientData = user;
        });
        break;
      }
    }

    if (patientData != null) {
      // Successful login
      final patient_id = patientData["PatientID"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("loggedUserId", patient_id);
      await prefs.setString("usertype", "Patient");
      
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "LOGIN SUCCESSFUL",
          text: "You may proceed to go to home page!",
        
          onConfirm: () async{
              await mongo.updateLastLoginDateTime("Patient", "PatientID", patient_id, DateTime.now().toLocal());

              OneSignal.login("P-$patient_id");
              Navigator.push(context, 
                MaterialPageRoute(builder: (context)=> PatientHomePage(id: patient_id, socket: widget.socket,))
              );
            }
          ),
        );
      }
      else {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "LOGIN FAIL",
            text: "Invalid Password!",
          ),
        );
      }

  }



  /**
   * GOOGLE SIGN IN
   */
  // Step 1
  String googleEmail = "";
  
  Future _handleSignIn() async {
    //await GoogleLogin.logout();
    final user = await GoogleLogin.login();
    print("Login with ${user?.email}");

    setState((){
      googleEmail = user?.email ?? '';
      emailCtrl.text = googleEmail;
    });

    // Replace these lines with your MongoDB connection details
    MongoDatabase mongo = MongoDatabase();

    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientEmail'] == emailCtrl.text) {
        setState(() {
          patientData = user;
        },);
        print(patientData);
        break;
      }
    }

    if (patientData != null) {
      // Successful login
      final patient_id = patientData["PatientID"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("loggedUserId", patient_id);
      await prefs.setString("usertype", "Patient");

      GoogleLogin.logout();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "LOGIN SUCCESSFUL",
          text: "You may proceed to go to home page!",
        
          onConfirm: ()async{
            /**
             * optionally update only the text field is not null
             */
           

            await mongo.updateLastLoginDateTime("Patient", "PatientID", patient_id, DateTime.now().toLocal());

            OneSignal.login("P-$patient_id");
            Navigator.push(context, 
              MaterialPageRoute(builder: (context)=> PatientHomePage(id: patient_id, socket: widget.socket,))
            );
          }
        ),
      );
    }
    else {
      GoogleLogin.logout();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "LOGIN FAIL",
          text: "Invalid Password!",
        ),
      );
    }
  }

  
  /* Future login() async{
    
    //192.168.8.119
    WebRequestController req = WebRequestController(
      path: "patient/login",
    );

    req.setBody(
      {
        'email': emailCtrl.text,
        'password':  passwordCtrl.text,
      }
    );

    await req.post();
    print(req.result());

    final patientData = req.result();

    if (req.status() == 200 && patientData.containsKey('msg') && patientData.containsKey('patient')) {
      // Successful login
      final patient = patientData['patient'];
      var patient_id = patient["PatientID"];
      
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "LOGIN SUCCESSFUL",
          text: "You may proceed to go to home page!",
        
          onConfirm: () async{
             /**
               * optionally update only the text field is not null
               */
              Map<String, dynamic> requestBody = {};

              DateTime now = DateTime.now();

              requestBody["LastLoginDateTime"] = now.toString();

              WebRequestController req = WebRequestController(
                path: "patient/update/id/$patient_id"
              );

              req.setBody(requestBody);
              await req.put();

              print("Update status: ${req.status()}");

              print(req.result());

              OneSignal.login("P-$patient_id");
              Navigator.push(context, 
                MaterialPageRoute(builder: (context)=> PatientHomePage(id: patient_id))
              );
            }
          ),
        );
      }
      else {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "LOGIN FAIL",
            text: "Invalid Password!",
          ),
        );
      }

  }

  /**
   * GOOGLE SIGN IN
   */
  // Step 1
  String googleEmail = "";
  
  Future _handleSignIn() async {
    //await GoogleLogin.logout();
    final user = await GoogleLogin.login();
    print("Login with ${user?.email}");

    setState((){
      googleEmail = user?.email ?? '';
      emailCtrl.text = googleEmail;
    });

    //192.168.8.119
    WebRequestController req = WebRequestController(
      path: "patient/loginGoogle/${googleEmail}",
    );
    await req.post();
    print(req.result());

    final patientData = req.result();

    if (req.status() == 200 && patientData.containsKey('msg') && patientData.containsKey('patient')) {
      // Successful login
      final patient = patientData['patient'];
      var patient_id = patient["PatientID"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("loggedUserId", patient_id);
      await prefs.setString("usertype", "Patient");

      GoogleLogin.logout();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "LOGIN SUCCESSFUL",
          text: "You may proceed to go to home page!",
        
          onConfirm: ()async{
            /**
             * optionally update only the text field is not null
             */
            Map<String, dynamic> requestBody = {};

            DateTime now = DateTime.now();

            requestBody["LastLoginDateTime"] = now.toString();

            WebRequestController req = WebRequestController(
              path: "patient/update/id/$patient_id"
            );

            req.setBody(requestBody);
            await req.put();

            print("Update status: ${req.status()}");

            print(req.result());
            OneSignal.login("P-$patient_id");
            Navigator.push(context, 
              MaterialPageRoute(builder: (context)=> PatientHomePage(id: patient_id))
            );
          }
        ),
      );
    }
    else {
      GoogleLogin.logout();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "LOGIN FAIL",
          text: "Invalid Password!",
        ),
      );
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
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginMenu())
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
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
                  
                  const SizedBox(height: 30),
                
                  Image.asset("images/Login.png", height: MediaQuery.of(context).size.height * 0.35,),
              
                  Text("Welcome back, patient!", style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 28, 
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF7F50),
                            offset: Offset(1.0, 2.0),
                            blurRadius: 4.0,
                          ),
                        ],
                  ), textAlign: TextAlign.justify,),
            
                  Text("Please enter email and password to login.", style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16
                  ),textAlign: TextAlign.justify,),
              
                  const SizedBox(height: 15.0),
              
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                      
                        // Add TextFormFields and ElevatedButton here.
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
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: GoogleFonts.poppins( color: Colors.white,),
                              prefixIcon: const Icon(Icons.email, color: Colors.white,),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                                color: Colors.red,
                              ),
                            ),
                            
                          ),
                        ),
              
                        const SizedBox(height: 15),
              
                        // Add TextFormFields and ElevatedButton here.
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
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            controller: passwordCtrl,
                            obscureText: !_password,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              hintText: 'Password',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: Tooltip(
                                message: _password ? 'Hide Password' : 'Show Password',
                                child: IconButton(
                                  onPressed: togglePassword,
                                  icon: Icon(_password
                                      ? Icons.visibility_off
                                      : Icons.visibility, color: Colors.white,),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
              
                        const SizedBox(height: 5),
              
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Forget Password?", style: GoogleFonts.poppins(
                                fontSize: 15.0, color: Colors.white,
                              )
                            ),
              
                            TextButton(
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgetPassword(role: "Patient")),
                                );
                              },
                              child: Text("Reset here", style: GoogleFonts.poppins(
                                  fontSize: 15.0, color: Colors.white,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            )
                          ],
                        ),
              
                        const SizedBox(height: 10),
              
                        InkWell(
                          onTap: (){
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing Data'), duration: Duration(seconds: 2),),
                              );
            
                              login();
                            }
                          },
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                
                                color: const Color(0xFFFF7F50),
                            
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0)
                                ),
            
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1f1f1f), // Shadow color
                                    offset: Offset(0, 2), // Offset of the shadow
                                    blurRadius: 4, // Spread of the shadow
                                    spreadRadius: 0, // Spread radius of the shadow
                                  ),
                                ],
              
                                border: Border.all(
                                  width: 2,
                                  color: Colors.white,
                                ),
              
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Login", style: GoogleFonts.poppins(
                                      fontSize: 20.0, color: Colors.black,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ],
                              )
                            ),
                          )
                        ),
              
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?", style: GoogleFonts.poppins(
                                fontSize: 16.0, color: Colors.white,
                              )
                            ),
              
                            TextButton(
                              onPressed: () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => RegisterMenu())
                              ),
                              child: Text("Sign Up here", style: GoogleFonts.poppins(
                                  fontSize: 16.0, color: Colors.white,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                          ],
                        ),
            
                        Text("OR", style: GoogleFonts.poppins(
                            fontSize: 16.0, color: Colors.white,
                          )
                        ),
            
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: (){
                                _handleSignIn();
                              },
                              icon: FaIcon(FontAwesomeIcons.google, size: 30, color: Colors.white,)
                            ),

                            //SizedBox(width: 10),

                            
                          ],
                        ),



                        SizedBox(height: 50),
            
            
                                      
                        
                      ],
                    ),
                  ),
            
                  
              
              
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}