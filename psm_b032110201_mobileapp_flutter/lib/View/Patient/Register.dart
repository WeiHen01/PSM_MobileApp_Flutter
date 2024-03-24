import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Login.dart';

import '../../Controller/Request Controller.dart';
import '../Register Menu.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailCtrl = TextEditingController();
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

  /**
   * Patient registration web service function
   */
  Future register() async{

    if(passwordCtrl.text != conPasswordCtrl.text){

    }
    else {
      /**
       * save the data registered to database
       */
      WebRequestController req = WebRequestController
        (server: "http://10.0.2.2:8080/api/", path: "patient/register");

      req.setBody(
        {
          "PatientName": 'new-user',
          "PatientEmail" : emailCtrl.text,
          "PatientPassword": passwordCtrl.text,
        }
      );

      await req.post();

      print(req.result());

      if (req.result() != null) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "SIGN UP SUCCESSFUL",
            text: "You may proceed to go to Login page now!",
            onConfirm: (){
              Navigator.push(context, 
                MaterialPageRoute(builder: (context)=> PatientLogin())
              );
            }
          ),
        );
      }

          
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: ()=>Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RegisterMenu())
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 10),
        decoration: const BoxDecoration(
          // set the background color of the container to be gradient
          gradient: LinearGradient(
            colors: [
              Color(0xFF301847), Color(0xFFC10214)
            ],
          ),

        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /**
                   * Illustration
                   */
              Image.asset("images/Register.png", height: MediaQuery.of(context).size.height * 0.35,),

              Text("Register as Patient", style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 28
              ), textAlign: TextAlign.start,),

              Text("Please register to login.", style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18
              ), textAlign: TextAlign.start,),

              const SizedBox(height: 15.0),

              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                          obscureText: !_password,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                          controller: passwordCtrl,
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
                          obscureText: !_confirmPass,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                          controller: conPasswordCtrl,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            hintText: 'Confirm Password',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            suffixIcon: Tooltip(
                              message: _confirmPass ? 'Hide Password' : 'Show Password',
                              child: IconButton(
                                onPressed: toggleconfirmPassword,
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
                
                      /**
                       * The text which navigate to login screen
                       * if user already has an existing account
                       */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Already have an account?",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              )),
                          TextButton(onPressed: (){
                            
                          }, 
                          child: Text("Login Now",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                            ),)
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /**
                       * The register button
                       */
                      InkWell(
                        onTap: (){
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')),
                            );

                            register();
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
                                Text("Register", style: GoogleFonts.poppins(
                                    fontSize: 20.0, color: Colors.black,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            )
                          ),
                        )
                      ),
                
                      SizedBox(height: 5),
                  
                      
                      
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}