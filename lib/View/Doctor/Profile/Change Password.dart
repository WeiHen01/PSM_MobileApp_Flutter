import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

//import '../../../Controller/Request Controller.dart';
import '../../../Controller/MongoDBController.dart';

class DoctorChangePassword extends StatefulWidget {

  final int? id;

  const DoctorChangePassword({Key? key, this.id});

  @override
  State<DoctorChangePassword> createState() => _DoctorChangePasswordState();
}

class _DoctorChangePasswordState extends State<DoctorChangePassword> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
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

  void toggleConfirmPassword()
  {
    setState(() {
      _confirmPass = !_confirmPass;
    });
  }

  Future<void> updatePassword() async{

    /**
     * optionally update only the text field is not null
     */
    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (passwordCtrl.text.isNotEmpty && conPasswordCtrl.text.isNotEmpty && conPasswordCtrl.text == passwordCtrl.text) {
      requestBody["DoctorPassword"] = passwordCtrl.text;
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
          text: "Your information is updated successfully!",
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
          text: "Failed to update your information!",
        ),
      );
    }
  }

  List<String>? _passwordErrors;

  void _validatePassword(String value) {
    setState(() {
      _passwordErrors = [];

      if (value.isEmpty) {
        _passwordErrors?.add('Please enter a password');
      } else {
        if (value.length < 8) {
          _passwordErrors?.add('Password must be at least 8 characters long.');
        }
        if (!RegExp(r'\d').hasMatch(value)) {
          _passwordErrors?.add('Password must contain at least 1 number.');
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_]').hasMatch(value)) {
          _passwordErrors?.add('Password must contain at least 1 special character.');
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
        _passwordMatchError = 'Passwords do not match.';
      } else {
        _passwordMatchError = null;
      }
    });
  }


  /* Future<void> updatePassword() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (passwordCtrl.text.isNotEmpty && conPasswordCtrl.text.isNotEmpty && conPasswordCtrl.text == passwordCtrl.text) {
      requestBody["DoctorPassword"] = passwordCtrl.text;
    }

    WebRequestController req = WebRequestController(
      path: "doctor/update/id/${widget.id}"
    );

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    if(req.status() == 200) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "UPDATE PASSWORD SUCCESSFUL",
          text: "Your password is updated successfully!",
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
          text: "Failed to update your password!",
        ),
      );
    }
  }  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Change Password", style: GoogleFonts.poppins(
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
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                  )
              ),
            ),

            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                              )
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 15.0),
                                              
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      
                                      Text("New Password", style: GoogleFonts.poppins(
                                          fontSize: 15.0, color: Colors.black,
                                        )
                                      ),
                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        obscureText: !_password,
                                        controller: passwordCtrl,
                                        onChanged: _validatePassword,
                                        decoration: InputDecoration(
                                          hintText: 'New Password',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.lock),
                                          suffixIcon: Tooltip(
                                            message: _password ? 'Hide Password' : 'Show Password',
                                            child: IconButton(
                                              onPressed: togglePassword,
                                              icon: Icon(_password
                                                  ? Icons.visibility_off
                                                  : Icons.visibility, color: Colors.black,),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                          errorStyle: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                          errorText: _passwordErrors?.join('\n'),
                                          errorMaxLines: 5,
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      Text("Confirm Password", style: GoogleFonts.poppins(
                                          fontSize: 15.0, color: Colors.black,
                                        )
                                      ),
                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        obscureText: !_confirmPass,
                                        controller: conPasswordCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Confirm Password',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.lock),
                                          suffixIcon: Tooltip(
                                            message: _confirmPass ? 'Hide Password' : 'Show Password',
                                            child: IconButton(
                                              onPressed: toggleConfirmPassword,
                                              icon: Icon(_confirmPass
                                                  ? Icons.visibility_off
                                                  : Icons.visibility, color: Colors.black,),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                          errorStyle: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 10,
                                          ),
                                          errorText: _passwordMatchError,
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
                                        onChanged: _validatePasswordsMatch,
                                      ),

                                      SizedBox(height: 30),

                                      Center(
                                        child: Text("Password settings", style: GoogleFonts.poppins(
                                            fontSize: 18.0, color: Colors.black,
                                            fontWeight: FontWeight.w600
                                          ), textAlign: TextAlign.center,
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:[
                                          

                                          Divider(
                                            color: Colors.black
                                          ),

                                          Text("1. Password must be at least 8 characters long.", style: GoogleFonts.poppins(
                                              fontSize: 13.0, color: Colors.black,
                                            ), textAlign: TextAlign.justify,
                                          ),

                                          Text("2. Password must contain at least 1 number.", style: GoogleFonts.poppins(
                                              fontSize: 13.0, color: Colors.black,
                                            ), textAlign: TextAlign.justify,
                                          ),

                                          Text("3. Password must contain at least 1 special character.", style: GoogleFonts.poppins(
                                              fontSize: 13.0, color: Colors.black,
                                            ), textAlign: TextAlign.justify,
                                          ),

                                          
                                        ]
                                      ),


                                      SizedBox(height: 50),

                                      InkWell(
                                        onTap: (){
                                          // Validate returns true if the form is valid, or false otherwise.
                                          if (_formKey.currentState!.validate()) {
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Processing Data')),
                                            );
                                            updatePassword();
                                          }
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
                                                    
                                      InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: Card(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)
                                              ),
                                                    
                                              border: GradientBoxBorder(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF301847), Color(0xFFC10214)
                                                  ]
                                                ),
                                                width: 4,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [

                                                Text("Cancel", style: GoogleFonts.poppins(
                                                    fontSize: 16.0, color: Colors.black,
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
                            )
                          ),
                        ),
                      ],
                    ),
                  ]
                )
              )
            )
          ],
        )
      ),
    );
  }
}