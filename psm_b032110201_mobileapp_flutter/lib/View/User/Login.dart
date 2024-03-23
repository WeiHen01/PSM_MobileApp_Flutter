import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Forget Password.dart';
import '../Login Menu.dart';
import '../Register Menu.dart';
import 'Home.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {

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
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 50),
              
                Image.asset("images/Login.png", height: MediaQuery.of(context).size.height * 0.35,),
            
                Text("Welcome back, patient!", style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 28
                )),

                Text("Please enter email and password to login.", style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16
                ),),
            
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
                                MaterialPageRoute(builder: (context) => ForgetPassword()),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserHomePage()),
                          );
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

                      IconButton(
                        onPressed: null,
                        icon: FaIcon(FontAwesomeIcons.google, size: 28, color: Colors.white,)
                      )


                                    
                      
                    ],
                  ),
                ),

                
            
            
              ],
            ),
          )
        ),
      )
    );
  }
}