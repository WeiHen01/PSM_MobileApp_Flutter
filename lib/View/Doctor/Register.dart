import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

//import '../../Controller/Request Controller.dart';
import '../../Controller/MongoDBController.dart';
import '../Login Menu.dart';
import '../Register Menu.dart';
import 'Google Login.dart';
import 'Login.dart';

class DoctorRegister extends StatefulWidget {
  const DoctorRegister({super.key});

  @override
  State<DoctorRegister> createState() => _DoctorRegisterState();
}

class _DoctorRegisterState extends State<DoctorRegister> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController conPasswordCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  
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

  Future _handleSignIn() async {
    final user = await GoogleLogin.login();
    print("Login with ${user?.email}");

    setState((){
      emailCtrl.text = user?.email ?? '';
    });

    await GoogleLogin.logout();
  }

  /**
   * Patient registration web service function
   */
  Future register() async{
    MongoDatabase mongo = MongoDatabase();
    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Doctor");

    bool isEmailRegistered = false;

    for (var user in userList) {
      if (user['DoctorEmail'] == emailCtrl.text) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "REGISTER FAIL",
            text: "This email has been registered before!",
          ),
        );
        isEmailRegistered = true;
        break;
      }
    }

     GoogleLogin.logout();

    // Proceed with registration if the email is not registered before
    if (!isEmailRegistered) {
      if (passwordCtrl.text != conPasswordCtrl.text) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "DIFFERENT PASSWORD",
            text: "Passwords do not match.",
          ),
        );
      } else {
        MongoDatabase db = MongoDatabase();

        // Increment the new doctor ID by 1
        var lists = await db.getCertainInfo("Doctor");
        int total = lists.length;
        int newDoctorID = total + 1;

        // Construct the doctor document
        Map<String, dynamic> doctorData = {
          "DoctorID": newDoctorID,
          "DoctorName": nameCtrl.text,
          "DoctorUsername": usernameCtrl.text,
          "DoctorContact": contactCtrl.text,
          "DoctorEmail": emailCtrl.text,
          "DoctorPassword": passwordCtrl.text,
          
        };

        // Store the doctor in MongoDB
        var result = await db.insert("Doctor", doctorData);

        if (result.isNotEmpty) {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "SIGN UP SUCCESSFUL",
              text: "You may proceed to go to the login page now!",
              onConfirm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorLogin()),
                );
              },
            ),
          );
        } else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "REGISTER FAIL",
              text: "Failed to register. Please try again later.",
            ),
          );
        }
      }
    }
  }
  /* Future register() async{

    if(passwordCtrl.text != conPasswordCtrl.text){
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "DIFFERENT PASSWORD",
          text: "Not the same match for password and confirm password.",
        ),
      );
    }
    else {
      /**
       * save the data registered to database
       */
      WebRequestController req = WebRequestController
        (path: "doctor/register");

      req.setBody(
        {
          "DoctorName": 'new-doctor',
          "DoctorEmail" : emailCtrl.text,
          "DoctorPassword": passwordCtrl.text,
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
                MaterialPageRoute(builder: (context)=> DoctorLogin())
              );
            }
          ),
        );
      }
      else{
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "REGISTER FAIL",
            text: "Sorry, fail to register!",
          ),
        );
      }

    } */
    
  List<String>? _emailErrors;
  List<String>? _passwordErrors;

  void _validateEmail(String value) {
    setState(() {
      _emailErrors = [];
      
      const emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
      final emailRegex = RegExp(emailPattern);
      
      if (value.isEmpty) {
        _emailErrors?.add('Please enter an email');
      } else {
        if (!emailRegex.hasMatch(value)) {
          _emailErrors?.add('Enter a valid email address');
        }
        if (!value.endsWith('.com')) {
          _emailErrors?.add('Email must end with .com');
        }
      }

      if (_emailErrors?.isEmpty ?? true) {
        _emailErrors = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordErrors = [];

      if (value.isEmpty) {
        _passwordErrors?.add('Please enter a password');
      } else {
        if (value.length < 8) {
          _passwordErrors?.add('Password must be at least 8 characters long');
        }
        if (!RegExp(r'\d').hasMatch(value)) {
          _passwordErrors?.add('Password must contain at least 1 number');
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_]').hasMatch(value)) {
          _passwordErrors?.add('Password must contain at least 1 special character');
        }
      }

      if (_passwordErrors?.isEmpty ?? true) {
        _passwordErrors = null;
      }
    });
  }

  String? _passwordMatchError;

  void _validatePasswordsMatch(String value) {
    setState(() {
      if (conPasswordCtrl != null && passwordCtrl.text != conPasswordCtrl.text) {
        _passwordMatchError = 'Passwords do not match';
      } else {
        _passwordMatchError = null;
      }
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /**
                     * Illustration
                     */
                Image.asset("images/Register_2.png", height: MediaQuery.of(context).size.height * 0.35,),
          
                Text("Register as Doctor", style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: 28,
                  shadows: [
                    Shadow(
                      color: Color(0xFFFF4081),
                      offset: Offset(1.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
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
                                return 'Please enter email';
                              }
                              return null;
                            },
                            controller: emailCtrl,
                            onChanged: _validateEmail,
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
                               errorText: _emailErrors?.join('\n'),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: GoogleFonts.poppins( // Set the text style for validation error message
                                color: Colors.white,
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
                                return 'Please enter name';
                              }
                              return null;
                            },
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              hintText: 'Name',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              prefixIcon: const Icon(FontAwesomeIcons.user, color: Colors.white),
                              
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
                                return 'Please enter username';
                              }
                              return null;
                            },
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            controller: usernameCtrl,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              hintText: 'Username',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              prefixIcon: const Icon(FontAwesomeIcons.user, color: Colors.white),
                              
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
                                return 'Please enter contact';
                              }
                              return null;
                            },
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            controller: contactCtrl,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              hintText: 'Contact',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              prefixIcon: const Icon(FontAwesomeIcons.phone, color: Colors.white),
                              
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
                                return 'Please enter password';
                              }
                              return null;
                            },
                            
                            obscureText: !_password,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            controller: passwordCtrl,
                            onChanged: _validatePassword,
                            decoration: InputDecoration(
                              errorText: _passwordErrors?.join('\n'),
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
                                color: Colors.white,
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
                                return 'Please enter confirm password';
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
                                  icon: Icon(_confirmPass
                                      ? Icons.visibility_off
                                      : Icons.visibility, color: Colors.white,),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              errorText: _passwordMatchError,
                            ),
                            onChanged: _validatePasswordsMatch,
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
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => LoginMenu()
                                )
                              );
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

                        Text("OR", style: GoogleFonts.poppins(
                            fontSize: 16.0, color: Colors.white,
                          )
                        ),
            
                        IconButton(
                          onPressed: (){
                            _handleSignIn();
                          },
                          icon: FaIcon(FontAwesomeIcons.google, size: 35, color: Colors.white,),
                        ),

                        SizedBox(height: 50),
                    
                  
                    ],
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