class Doctor {
  int doctorID = 0;
  String doctorName = "";
  String? doctorUsername;
  String? doctorGender;
  String? doctorSpecialize;
  String doctorEmail = "";
  String? doctorContact;
  String doctorPassword = "";
  String? doctorPhoto;
  DateTime? lastLoginDateTime;
  DateTime? lastUpdateDateTime;

  Doctor(
    this.doctorID,
    this.doctorName,
    this.doctorUsername,
    this.doctorGender,
    this.doctorSpecialize,
    this.doctorEmail,
    this.doctorContact,
    this.doctorPassword,
    this.doctorPhoto,
    this.lastLoginDateTime,
    this.lastUpdateDateTime,
  );

  Doctor.fromJson(Map<String, dynamic> json)
      : doctorID = json["DoctorID"],
        doctorName = json["DoctorName"],
        doctorUsername = json["DoctorUsername"] != null
            ? json["DoctorUsername"] 
            : null,
        doctorGender = json["DoctorGender"] != null
            ? json["DoctorGender"] 
            : null,
        doctorSpecialize = json["DoctorSpecialize"] != null
            ? json["DoctorSpecialize"] 
            : null,
        doctorEmail = json["DoctorEmail"], 
        doctorContact = json["DoctorContact"] != null
            ? json["DoctorContact"] 
            : null,
        doctorPassword = json["DoctorPassword"], 
        doctorPhoto = json["DoctorPhoto"] != null
            ? json["DoctorPhoto"] 
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
  int get doctorid => doctorID;
  set patientid(int value) => doctorID = value;

  String get doctorname => doctorName;
  set doctorname(String value) => doctorName = value;

  String? get doctorusername => doctorUsername;
  set doctorusername(String? value) => doctorUsername = value;

  String? get doctorgender => doctorGender;
  set doctorgender(String? value) => doctorGender = value;

  String? get doctorspecialize => doctorSpecialize;
  set doctorspecialize(String? value) => doctorSpecialize = value;

  String get doctoremail => doctorEmail;
  set doctoremail(String value) => doctorEmail = value;

  String? get doctorcontact => doctorContact;
  set doctorcontact(String? value) => doctorContact = value;

  String get doctorpassword => doctorPassword;
  set doctorpassword(String value) => doctorPassword = value;

  String? get doctorphoto => doctorPhoto;
  set doctorphoto(String? value) => doctorPhoto = value;

  DateTime? get lastLogin => lastLoginDateTime;
  set lastLogin(DateTime? value) => lastLoginDateTime = value;

  DateTime? get lastUpdate => lastUpdateDateTime;
  set lastUpdate(DateTime? value) => lastUpdateDateTime = value;
}
