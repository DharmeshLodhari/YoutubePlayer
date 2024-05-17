class ChatMessageSettings {
  bool? playIncomingMessageSound;
  bool? playOutgoingMessageSound;
  bool? accountBalanceVisibility;

  ChatMessageSettings({
    this.playIncomingMessageSound = true,
    this.playOutgoingMessageSound = true,
    this.accountBalanceVisibility = false,
  });

  factory ChatMessageSettings.fromJson(Map<String, dynamic> json) {
    return ChatMessageSettings(
      playIncomingMessageSound: json['playIncomingMessageSound'],
      playOutgoingMessageSound: json['playOutgoingMessageSound'],
      accountBalanceVisibility: json['accountBalanceVisibility'],
    );
  }
  factory ChatMessageSettings.fromDBJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return ChatMessageSettings();
    }

    return ChatMessageSettings(
      playIncomingMessageSound:
          json['playIncomingMessageSound'] == 1 ? true : false,
      playOutgoingMessageSound:
          json['playOutgoingMessageSound'] == 1 ? true : false,
      accountBalanceVisibility:
          json['accountBalanceVisibility'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['playIncomingMessageSound'] = this.playIncomingMessageSound;
    data['playOutgoingMessageSound'] = this.playOutgoingMessageSound;
    data['accountBalanceVisibility'] = this.accountBalanceVisibility;
    return data;
  }

  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['playIncomingMessageSound'] =
        this.playIncomingMessageSound == true ? 1 : 0;
    data['playOutgoingMessageSound'] =
        this.playOutgoingMessageSound == true ? 1 : 0;
    data['accountBalanceVisibility'] =
        this.accountBalanceVisibility == true ? 1 : 0;
    return data;
  }
}
