import 'dart:typed_data';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:http/http.dart' as http;
import 'package:local_ip_plugin/local_ip_plugin.dart';
import 'package:network_info_plus/network_info_plus.dart';

// import '../../../Controller/Request Controller.dart';
import '../../../Controller/MongoDBController.dart';
import 'Profile.dart';

class PatientEditProfile extends StatefulWidget {
  
  final int? id;

  PatientEditProfile({Key? key, this.id});

  @override
  State<PatientEditProfile> createState() => _PatientEditProfileState();
}

class _PatientEditProfileState extends State<PatientEditProfile> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();

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

        print("Image selected" + _image!.path);
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
        print("Image selected" + _image!.path);
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
        'http://$server:8000/api/patient/profileImage/${widget.id}')
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

  String name = "", username = "", patient_email = "", address = "" , contact = "", gender = "";
  String? profileImgPath;

  String? base64Image;
  
  Future<void> updateProfileImage() async {
    // Define the endpoint URL
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      // 10.131.78.79
      // 192.168.109.212
      // 10.0.2.2
      // 192.168.8.119
    String? server = await prefs.getString("localhost");
    final String endpoint = 'http://$server:8000/api/patient/updatePhoto/${widget.id}';

    // Create a multipart request
    var request = http.MultipartRequest('PUT', Uri.parse(endpoint));

    // Attach the image file to the request
    request.files.add(await http.MultipartFile.fromPath('PatientPhoto', _image!.path));

    try {
      // Send the request
      var response = await request.send();

      // Check the response status code
      if (response.statusCode == 200) {
        print('Profile picture updated successfully');
        MongoDatabase mongo = MongoDatabase();
        await mongo.updateLastUpdateDateTime("Patient", "PatientID", widget.id, DateTime.now().toLocal());
      
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "UPDATE PROFILE IMAGE SUCCESSFUL",
            text: "Your profile picture is updated successfully!",
          ),
        );
      } else {
        print('Failed to update profile picture');
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "UPDATE FAILURE",
            text: "Failed to update your profile picture!",
          ),
        );
      }
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }


  final List<String> genderItems = [
    'Male',
    'Female',
  ];

  String? selectedValue ;

  // Future<void> updateProfileImage() async {
  //   if (_image == null) {
  //     return;
  //   }

  //   final bytes = await File(_image!.path).readAsBytes();
  //   base64Image = base64Encode(bytes);

  //   MongoDatabase mongo = MongoDatabase();
  //   Map<String, dynamic> requestBody = {};

  //   if(_image != null){
  //     requestBody["PatientPhoto"] = base64Image;
  //   }

  //   bool updateResult = await mongo.update("Patient", "PatientID", widget.id, requestBody);
    
  //   if(updateResult) {
  //     await mongo.updateLastUpdateDateTime("Patient", "PatientID", widget.id, DateTime.now().toLocal());
      
  //     ArtSweetAlert.show(
  //       context: context,
  //       artDialogArgs: ArtDialogArgs(
  //         type: ArtSweetAlertType.success,
  //         title: "UPDATE PROFILE IMAGE SUCCESSFUL",
  //         text: "Your profile picture is updated successfully!",
  //       ),
  //     );
  //   }
  //   else
  //   {
  //    ArtSweetAlert.show(
  //       context: context,
  //       artDialogArgs: ArtDialogArgs(
  //         type: ArtSweetAlertType.danger,
  //         title: "UPDATE FAILURE",
  //         text: "Failed to update your profile picture!",
  //       ),
  //     );
  //   }

  // }

  // // Function to retrieve profile image from MongoDB
  // Future<Uint8List?> getProfileImage(String patientID) async {
  //   MongoDatabase mongo = MongoDatabase();
  //   await mongo.open("Patient");

  //   Map<String, dynamic> query = {
  //     "PatientID": patientID,
  //   };

  //   final patients = await mongo.getByQuery('Patient', query);

  //   if (patients.isNotEmpty) {
  //     // Assuming 'PatientPhoto' is the field containing the image in bytes
  //     List<int>? imageBytes = patients[0]['PatientPhoto'];
  //     if (imageBytes != null) {
  //       // Convert bytes to Uint8List
  //       return Uint8List.fromList(imageBytes);
  //     }
  //   }

  //   return null; // Return null if no image found or error occurred
  // }

  Future<void> getProfile () async {

    MongoDatabase mongo = MongoDatabase();
    await mongo.open("Patient");
    // Find the user by email and password
    var userList = await mongo.getCertainInfo("Patient");
    var patientData;
    for (var user in userList) {
      if (user['PatientID'] == widget.id) {
        setState((){
          patientData = user;
          name = patientData["PatientName"] ?? "";
          patient_email = patientData["PatientEmail"] ?? "";
          address = patientData["PatientAddress"] ?? "";
          contact = patientData["PatientContact"] ?? "";
          username = patientData["PatientUsername"] ?? "";
          gender = patientData["PatientGender"] ?? "";

          print("Patient: $patient_email, Gender: $gender");
         
          nameCtrl.text = name;
          emailCtrl.text = patient_email;
          contactCtrl.text = contact;
          usernameCtrl.text = username;
          addressCtrl.text = address;
          selectedValue = gender;
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
      requestBody["PatientName"] = nameCtrl.text;
    }

    if (usernameCtrl.text != '' && usernameCtrl.text.isNotEmpty) {
      requestBody["PatientUsername"] = usernameCtrl.text;
    }

    if (emailCtrl.text != '' && emailCtrl.text.isNotEmpty) {
      requestBody["PatientEmail"] = emailCtrl.text;
    }

    if (contactCtrl.text != '' && contactCtrl.text.isNotEmpty) {
      requestBody["PatientContact"] = contactCtrl.text;
    }

    if (addressCtrl.text != '' && addressCtrl.text.isNotEmpty) {
      requestBody["PatientAddress"] = addressCtrl.text;
    }

    if(selectedValue != '' && selectedValue!.isNotEmpty){
      requestBody["PatientGender"] = selectedValue;
    }

    MongoDatabase mongo = MongoDatabase();

    bool updateResult = await mongo.update("Patient", "PatientID", widget.id, requestBody);

    
    if(updateResult) {
      await mongo.updateLastUpdateDateTime("Patient", "PatientID", widget.id, DateTime.now().toLocal());
      
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

  String ipAddress = 'Loading...';

  void getLocalIP() async {
    String localIP = await LocalIpPlugin.getLocalIP();
    print('My local IP: $localIP');
  }

  
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalIP();
    MongoDatabase db = MongoDatabase();
    db.open("Patient");
    getProfile();
    fetchProfileImage();
    
  }

  /* Future<void> getProfile () async {
    WebRequestController req = WebRequestController(
      path: "patient/findPatient/${widget.id}"
    );

    await req.get();

    try{
      
      if (req.status()== 200) {
        
        var data = req.result();

        setState((){
          name = data["PatientName"] ?? "";
          patient_email = data["PatientEmail"] ?? "";
          address = data["PatientAddress"] ?? "";
          contact = data["PatientContact"] ?? "";
          username = data["PatientUsername"] ?? "";

          String profileImg = data["PatientPhoto"] ?? "";

          profileImgPath = "$profileImg";

          print("Patient: $patient_email");
         
          nameCtrl.text = name;
          emailCtrl.text = patient_email;
          addressCtrl.text = address;
          contactCtrl.text = contact;
          usernameCtrl.text = username;

        });
        
      }
    }catch (e) {
      print('Error fetching patient : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }

  } */

   /* Future<void> updateAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? localhost = await prefs.getString("localhost");
      // Create a multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://${localhost}:8000/api/patient/updateProfile/id/${widget.id}'),
      );

      // Add updated patient information to the request body
      if (nameCtrl.text != null && nameCtrl.text.isNotEmpty) {
        request.fields['PatientName'] = nameCtrl.text;
      }

      if (usernameCtrl.text != null && usernameCtrl.text.isNotEmpty) {
        request.fields['PatientUsername'] = usernameCtrl.text;
      }

      if (emailCtrl.text != null && emailCtrl.text.isNotEmpty) {
        request.fields['PatientEmail'] = emailCtrl.text;
      }

      if (addressCtrl.text != null && addressCtrl.text.isNotEmpty) {
        request.fields['PatientAddress'] = addressCtrl.text;
      }

      if (contactCtrl.text != null && contactCtrl.text.isNotEmpty) {
        request.fields['PatientContact'] = contactCtrl.text;
      }
      

      // Add patient photo to the request if available
      if (_image != null) {
        var photoStream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();

        var multipartFile = http.MultipartFile(
          'PatientPhoto',
          photoStream,
          length,
          filename: _image!.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();

      // Check the status code
      if (response.statusCode == 200) {
        /**
         * optionally update only the text field is not null
         */
        Map<String, dynamic> requestBody = {};

        DateTime now = DateTime.now();

        requestBody["LastUpdateDateTime"] = now.toString();

        WebRequestController req = WebRequestController(
          path: "patient/update/id/${widget.id}"
        );

        req.setBody(requestBody);
        await req.put();

        print("Update status: ${req.status()}");

        print(req.result());
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "UPDATE SUCCESSFUL",
            text: "Your information is updated successfully!",
          ),
        );
      } else {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "UPDATE FAILURE",
            text: "Failed to update your information!",
          ),
        );
      }
    } catch (error) {
      print('Error updating account: $error');
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "UPDATE ERROR",
          text: "An error occurred while updating your information!",
        ),
      );
    }
  }  */

  /* Future<void> updateAccount() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (nameCtrl.text != null && nameCtrl.text.isNotEmpty) {
      requestBody["PatientName"] = nameCtrl.text;
    }

    if (usernameCtrl.text != null && usernameCtrl.text.isNotEmpty) {
      requestBody["PatientUsername"] = usernameCtrl.text;
    }

    if (emailCtrl.text != null && emailCtrl.text.isNotEmpty) {
      requestBody["PatientEmail"] = emailCtrl.text;
    }

    if (addressCtrl.text != null && addressCtrl.text.isNotEmpty) {
      requestBody["PatientAddress"] = addressCtrl.text;
    }

    if (contactCtrl.text != null && contactCtrl.text.isNotEmpty) {
      requestBody["PatientContact"] = contactCtrl.text;
    }

    WebRequestController req = WebRequestController(
      server: "http://10.0.2.2:8000/api/", path: "patient/updateProfile/id/${widget.id}"
    );

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    if(req.status() == 200) {
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
          text: "Fail to update your information!",
        ),
      );
    }
  } */

  

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
                  top: MediaQuery.of(context).size.height * 0.1,
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
                                        fontSize: 18.0, fontWeight: FontWeight.w600
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

                                      GradientText(
                                        "Address",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
                                      ),
                                      // Add TextFormFields and ElevatedButton here.
                                      TextFormField(
                                        
                                        controller: addressCtrl,
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

                                      SizedBox(height: 10),

                                      GradientText(
                                        "Gender",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.0
                                        ),
                                        colors: [
                                            Color(0xFF301847), Color(0xFFC10214)
                                        ],
                                      ),

                                      DropdownButtonFormField2<String>(
                                        value: selectedValue,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            // Add Horizontal padding using menuItemStyleData.padding so it matches
                                            // the menu padding when button's width is not specified.
                                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                            hintStyle: GoogleFonts.poppins(
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: Icon(FontAwesomeIcons.userCheck, color: Colors.black),
                                            errorStyle:  GoogleFonts.poppins( // Set the text style for validation error message
                                              color: Colors.red,
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFFF0F0F0)
                                            // Add more decoration..
                                          ),
                                          hint: Text(
                                            'Select Your Gender',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black, fontSize: 12,
                                            ),
                                          ),
                                          items: genderItems
                                              .map((item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select gender.';
                                            }
                                            return null;
                                          },
                                          
                                          onChanged: (value) {
                                            //Do something when selected item is changed.
                                            selectedValue = value.toString();
                                          },
                                          onSaved: (value) {
                                            selectedValue = value.toString();
                                          },
                                          buttonStyleData: const ButtonStyleData(
                                            padding: EdgeInsets.only(right: 8),
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                            iconSize: 30,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              color: Color(0xFFFF7F50),
                                            ),
                                          ),
                                          menuItemStyleData: const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(horizontal: 16),
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
                                            updateProfileImage();
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
                                        onTap: () => Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context)=>PatientProfile(id: widget.id)
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