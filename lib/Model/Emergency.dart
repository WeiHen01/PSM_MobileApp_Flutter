class Emergency {
  int callID = 0;
  DateTime? callDateTime;
  String targetNumber;
  int patient = 0;

  Emergency(
    this.callID , this.callDateTime , this.targetNumber, this.patient 
  );

  Emergency.fromJson(Map<String, dynamic> json)
  : callID = json["CallingID"] ?? 0,
    callDateTime = json["CallingTimestamp"] != null
      ? json["CallingTimestamp"]
      : null,
    targetNumber = json["TargetNumber"] ?? "",
    patient = json["PatientID"] ?? "";

  /**
   * getters and setters
   */
  int get _callID => callID;
  set _callID(int value) => callID = value;

  DateTime? get _callDateTime => callDateTime;
  set _callDateTime(DateTime? value) => callDateTime = value;

  String get _targetNumber => targetNumber;
  set _targetNumber(String value) => targetNumber = value;


  int get _patient => patient;
  set _patient(int value) => patient = value;

}