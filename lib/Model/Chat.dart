class Chat {
  int chatID = 0;
  String chatMessage = "";
  DateTime? chatDateTime;
  String chatStatus = "";
  String receiver = "";
  String patient = "";

  Chat(
    this.chatID,
    this.chatMessage,
    this.chatDateTime,
    this.chatStatus,
    this.receiver,
    this.patient,
  );

  Chat.fromJson(Map<String, dynamic> json)
      : chatID = json["ChatID"] ?? 0,
        chatMessage = json["ChatMessage"] ?? "",
        chatDateTime = json["ChatDateTime"] != null
          ? json["ChatDateTime"]
          : null,
        chatStatus = json["ChatMessageStatus"] ?? "",
        receiver = json["ReceiverID"] ?? "",
        patient = json["PatientID"] ?? "";


  /**
   * getters and setters
   */
  int get _chatID => chatID;
  set _chatID(int value) => chatID = value;

  String get _chatMessage => chatMessage;
  set _chatMessage(String value) => chatMessage = value;

  DateTime? get _chatDateTime => chatDateTime;
  set _chatDateTime(DateTime? value) => chatDateTime = value;

  String get _chatStatus => chatStatus;
  set _chatStatus(String value) => chatStatus = value;

  String get _receiver => receiver;
  set _receiver(String value) => receiver = value;

  String get _patient => patient;
  set _patient(String value) => patient = value;
}
