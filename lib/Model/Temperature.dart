class Temperature {
  int tempID = 0;
  int temperature = 0;
  DateTime? measureDate;
  DateTime? measureTime;
  String? patient;

  Temperature(
    this.tempID,
    this.temperature,
    this.measureDate,
    this.measureTime,
    this.patient
  );

  Temperature.fromJson(Map<String, dynamic> json)
      : tempID = json["TempID"],
        temperature = json["Temperature"],
        measureDate = json["MeasureDate"] != null
            ? json["MeasureDate"]
            : null,
        measureTime = json["MeasureTime"] != null
            ? json["MeasureTime"]
            : null,
        patient = json["PatientID"];


  /**
   * getters and setters
   */
  int get _tempId => tempID;
  set _tempId(int value) => tempID = value;

  int get _temperature => temperature;
  set _temperature(int value) => temperature = value;

  String? get _patient => patient;
  set _patient(String? value) => patient = value;

  DateTime? get date => measureDate;
  set date(DateTime? value) => measureDate = value;

  DateTime? get time => measureTime;
  set time(DateTime? value) => measureTime = value;
}
