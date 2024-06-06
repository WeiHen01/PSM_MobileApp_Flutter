class Pulse {
  int pulseID = 0;
  int pulseRate = 0;
  DateTime? MeasureDate;
  DateTime? MeasureTime;
  String? patient;

  Pulse(
    this.pulseID,
    this.pulseRate,
    this.MeasureDate,
    this.MeasureTime,
    this.patient
  );

  Pulse.fromJson(Map<String, dynamic> json)
      : pulseID = json["PulseID"],
        pulseRate = json["PulseRate"],
        MeasureDate = json["MeasureDate"]!= null
            ? json["MeasureDate"]
            : null,
        MeasureTime = json["MeasureTime"]!= null
            ? json["MeasureTime"]
            : null,
        patient = json["TempID"];


  /**
   * getters and setters
   */
  int get _pulseID => pulseID;
  set _pulseID(int value) => pulseID = value;

  int get _pulse => pulseRate;
  set _pulse(int value) => pulseRate = value;

  String? get _patient => patient;
  set _patient(String? value) => patient = value;

  DateTime? get date => MeasureDate;
  set date(DateTime? value) => MeasureDate = value;

  DateTime? get time => MeasureTime;
  set time(DateTime? value) => MeasureTime = value;
}
