import 'dart:io';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:http/http.dart' as http;

//import '../../../Controller/Request Controller.dart';
import '../../../Controller/MongoDBController.dart';
import 'Profile.dart';

class DoctorEditProfile extends StatefulWidget {

  final int? id;
  DoctorEditProfile({Key? key, this.id});

  @override
  State<DoctorEditProfile> createState() => _DoctorEditProfileState();
}

class _DoctorEditProfileState extends State<DoctorEditProfile> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();

  ImagePicker picker = ImagePicker();
  File? _image;

  /// Get from gallery
  _getFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String imageUrl = "images/Profile_2.png";
  late Uint8List? _images = Uint8List(0); // Default image URL

  // Default image URL
  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8000/api/doctor/profileImage/${widget.id}')
    );

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

 
  String? profileImgPath;
  String name = "", username = "", doctor_email = "", contact = "";

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
          name = doctorData["DoctorName"];
          doctor_email = doctorData["DoctorEmail"] ?? "";
          contact = doctorData["DoctorContact"] ?? "";
          username = doctorData["DoctorUsername"] ?? "";

          print("Patient: $doctor_email");
         
          nameCtrl.text = name;
          emailCtrl.text = doctor_email;
          contactCtrl.text = contact;
          usernameCtrl.text = username;
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

    if (nameCtrl.text != '' && nameCtrl.text.isNotEmpty) {
      requestBody["DoctorName"] = nameCtrl.text;
    }

    if (usernameCtrl.text != '' && usernameCtrl.text.isNotEmpty) {
      requestBody["DoctorUsername"] = usernameCtrl.text;
    }

    if (emailCtrl.text != '' && emailCtrl.text.isNotEmpty) {
      requestBody["DoctorEmail"] = emailCtrl.text;
    }

    if (contactCtrl.text != '' && contactCtrl.text.isNotEmpty) {
      requestBody["DoctorContact"] = contactCtrl.text;
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

  /* Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      path: "doctor/findDoctor/${widget.id}"
    );

    await req.get();

    try{
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["DoctorName"] ?? "";
          doctor_email = data["DoctorEmail"] ?? "";
          contact = data["DoctorContact"] ?? "";
          username = data["DoctorUsername"] ?? "";


          print("Patient: $doctor_email");
         
          nameCtrl.text = name;
          emailCtrl.text = doctor_email;
          contactCtrl.text = contact;
          usernameCtrl.text = username;
        });
        
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

  /* Future<void> updateAccount() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (nameCtrl.text != null && nameCtrl.text.isNotEmpty) {
      requestBody["DoctorName"] = nameCtrl.text;
    }

    if (usernameCtrl.text != null && usernameCtrl.text.isNotEmpty) {
      requestBody["DoctorUsername"] = usernameCtrl.text;
    }

    if (emailCtrl.text != null && emailCtrl.text.isNotEmpty) {
      requestBody["DoctorEmail"] = emailCtrl.text;
    }

    if (contactCtrl.text != null && contactCtrl.text.isNotEmpty) {
      requestBody["DoctorContact"] = contactCtrl.text;
    }

    WebRequestController req = WebRequestController(
      path: "doctor/update/id/${widget.id}"
    );

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Map<String, dynamic> requestBody = {};

      DateTime now = DateTime.now();

      requestBody["LastUpdateDateTime"] = now.toString();

      WebRequestController req = WebRequestController(
        path: "doctor/update/id/${widget.id}"
      );

      req.setBody(requestBody);
      await req.put();

      print("Update status: ${req.status()}");
      
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
  } */


  
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
    fetchProfileImage();
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
          onPressed: () => Navigator.pop(context),
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
                  top: MediaQuery.of(context).size.width * 0.2,
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

                                Container(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4.0,
                                            ),
                                            image: _image != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(_image!),
                                            )
                                            : _images != null
                                              ? DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: MemoryImage(_images!),
                                                )
                                              : DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(imageUrl),
                                                ),
                                          ), 
                                        ),
                                                
                                      ],
                                    ),
                                  ),
                                ),

                                TextButton(onPressed: (){
                                  showDialog(
                                    context: context, 
                                    builder: (_) {
                                      return Dialog(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom:15),
                                          height: 200,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF301847), Color(0xFFC10214)
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(10.0)
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 5),

                                              Text("Upload Photo", style: GoogleFonts.poppins(
                                                  fontSize: 25.0, color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                                )
                                              ),

                                              Divider(
                                                color: Colors.white,
                                                thickness: 1.5,
                                              ),

                                              SizedBox(height: 15),

                                              Text("Please select photo upload option: ", style: GoogleFonts.poppins(
                                                  fontSize: 15.0, color: Colors.white,
                                                )
                                              ),

                                              Spacer(),

                                              Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                      onTap: (){
                                                        _getFromGallery();
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.photo, color: Colors.white,),

                                                          SizedBox(width: 5),

                                                          Text("Gallery", style: GoogleFonts.poppins(
                                                              fontSize: 15.0, color: Colors.white,
                                                            )
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    InkWell(
                                                      onTap: (){
                                                        _getFromCamera();
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.camera, color: Colors.white,),
                                                      
                                                          SizedBox(width: 5),
                                                      
                                                          Text("Camera", style: GoogleFonts.poppins(
                                                              fontSize: 15.0, color: Colors.white,
                                                            )
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ]
                                                )
                                              )


                                            ],
                                          ),
                                          
                                        )

                                      );

                                    }

                                  );
                                }, child: GradientText(
                                    "Edit this profile",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.0
                                    ),
                                    colors: [
                                        Color(0xFF301847), Color(0xFFC10214)
                                    ],
                                ),),
                                              
                                const Divider(),

                                const SizedBox(height: 15.0),
                                              
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      
                                      GradientText(
                                        "Name",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
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


                                      GradientText(
                                        "Username",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
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
                                        controller: usernameCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Username',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.person_outline_rounded),
                                          filled: true,
                                          fillColor: Color(0xFFF0F0F0),
                                        ),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      
                                      GradientText(
                                        "Email",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
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
                                        controller: emailCtrl,
                                        keyboardType: TextInputType.emailAddress,
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

                                      GradientText(
                                        "Contact",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
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
                                        controller: contactCtrl,
                                        decoration: InputDecoration(
                                          hintText: 'Contact',
                                          hintStyle: GoogleFonts.poppins(),
                                          prefixIcon: Icon(Icons.phone),
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

                                            updateAccount();
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
                                            builder: (context)=>DoctorProfile(id: widget.id)
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
        
          ],
        ),
      ),
    );
  }
}