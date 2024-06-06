class Patient {
  int patientID = 0;
  String patientName = "";
  String? patientUsername;
  String? patientGender;
  String? patientBiography;
  String? patientAddress;
  String patientEmail = "";
  String? patientContact;
  String patientPassword = "";
  String? patientPhoto;
  DateTime? lastLoginDateTime;
  DateTime? lastUpdateDateTime;

  Patient(
    this.patientID,
    this.patientName,
    this.patientUsername,
    this.patientGender,
    this.patientBiography,
    this.patientAddress,
    this.patientEmail,
    this.patientContact,
    this.patientPassword,
    this.patientPhoto,
    this.lastLoginDateTime,
    this.lastUpdateDateTime,
  );

  Patient.fromJson(Map<String, dynamic> json)
      : patientID = json["PatientID"],
        patientName = json["PatientName"],
        patientUsername = json["PatientUsername"] != null
            ? json["PatientUsername"] 
            : null,
        patientGender = json["PatientGender"] != null
            ? json["PatientGender"] 
            : null,
        patientBiography = json["PatientBiography"] != null
            ? json["PatientBiography"] 
            : null,
        patientAddress = json["PatientAddress"] != null
            ? json["PatientAddress"] 
            : null,
        patientEmail = json["PatientEmail"], 
        patientContact = json["PatientContact"] != null
            ? json["PatientContact"] 
            : null,
        patientPassword = json["PatientPassword"], 
        patientPhoto = json["PatientPhoto"] != null
            ? json["PatientPhoto"] 
            : null,
        lastLoginDateTime = json["LastLoginDateTime"] is String
            ? DateTime.parse(json["LastLoginDateTime"]["\$date"])
            : null,
        lastUpdateDateTime = json["LastUpdateDateTime"] is String
            ? DateTime.parse(json["LastUpdateDateTime"]["\$date"])
            : null;


  /**
   * getters and setters
   */
  int get patientid => patientID;
  set patientid(int value) => patientID = value;

  String get patientname => patientName;
  set patientname(String value) => patientName = value;

  String? get patientusername => patientUsername;
  set patientusername(String? value) => patientUsername = value;

  String? get patientgender => patientGender;
  set patientgender(String? value) => patientGender = value;

  String? get patientbiography => patientBiography;
  set patientbiography(String? value) => patientBiography = value;

  String? get patientaddress => patientAddress;
  set patientaddress(String? value) => patientAddress = value;

  String get patientemail => patientEmail;
  set patientemail(String value) => patientEmail = value;

  String? get patientcontact => patientContact;
  set patientcontact(String? value) => patientContact = value;

  String get patientpassword => patientPassword;
  set patientpassword(String value) => patientPassword = value;

  String? get patientphoto => patientPhoto;
  set patientphoto(String? value) => patientPhoto = value;

  DateTime? get lastLogin => lastLoginDateTime;
  set lastLogin(DateTime? value) => lastLoginDateTime = value;

  DateTime? get lastUpdate => lastUpdateDateTime;
  set lastUpdate(DateTime? value) => lastUpdateDateTime = value;
}
