import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import 'Profile.dart';

class PatientEditProfile extends StatefulWidget {
  
  final int? id;
  final String? name;
  final String? email;

  PatientEditProfile({Key? key, this.id, this.name, this.email});

  @override
  State<PatientEditProfile> createState() => _PatientEditProfileState();
}

class _PatientEditProfileState extends State<PatientEditProfile> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameCtrl.text = widget.name ?? '';
    emailCtrl.text = widget.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Edit Profile", style: GoogleFonts.poppins(
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
                                              
                                const SizedBox(height: 40.0),
                                              
                                const Divider(),

                                const SizedBox(height: 15.0),
                                              
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        controller: nameCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Name',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.person),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        controller: emailCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.email),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Address',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.place),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
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
                                        onTap: ()=>Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context)=>PatientProfile()
                                          )
                                        ),
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
              
                    
        
        
        
        
        
                  ],
                ),
              ),
            ),
        
            Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 100),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                    
                        )
                        
                      ),
                    ),
                            
                  ],
                ),
              ),
            ),

            Positioned(
              top: 170, // Adjust this value to change the position of the IconButton
              right: 150, 
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF301847), Color(0xFFC10214)
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 4.0,
                  )
                ),
                child: const IconButton(
                  onPressed: null, 
                  icon: Icon(
                    Icons.camera_alt_rounded, 
                    color: Colors.white,
                    size: 20,
                  ),
                )
              )
            )
        
        
          ],
        ),
      ),
    );
  }
}