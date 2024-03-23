import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  final _formKey = GlobalKey<FormState>();

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("images/Reset_password.png", height: 450),

              Text("FORGET PASSWORD",
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
                    Text("Please enter the email address when you joined and "
                        "we will send you instruction to reset your password",
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
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            prefixIcon: Icon(Icons.mail, color: Colors.white),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter your email address",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.white,
                            ),
                            labelText: "Enter your email address",
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
        )
      )
    );
  }
}