/// id : "5f9d4ea7-edef-4763-b48b-2806da5f9095"
/// merchant : "sanxynet"
/// type : "popup"
/// start_date : ""
/// end_date : ""
/// message : "Your food is ready"

class FlashTagAlertModel {
  FlashTagAlertModel({
    this.id,
    this.merchant,
    this.title,
    this.type,
    this.startDate,
    this.endDate,
    this.updatedAt,
    this.message,
    this.isActive = true,
  }) {
    type ??= FlashTagCategory("Crawling Text");
  }

  FlashTagAlertModel.fromJson(dynamic json) {
    id = json['id'];
    merchant = json['merchant'];
    title = json['title'];
    type = FlashTagCategory(json['type']);

    if (json['start_date'] != null) {
      startDate = DateTime.parse(json['start_date']);
    }

    if (json['end_date'] != null) {
      endDate = DateTime.parse(json['end_date']);
    }
    if (json['updated_at'] != null) {
      updatedAt = DateTime.parse(json['updated_at']);
    }

    message = json['message'];
    isActive = json['is_active'] ?? true;
  }

  String? id;
  String? merchant;
  String? title;
  FlashTagCategory? type;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? updatedAt;
  String? message;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['merchant'] = merchant;
    map['title'] = title;
    map['type'] = type?.toValue();
    if (startDate != null) {
      map['start_date'] = startDate?.toString();
    }

    if (endDate != null) {
      map['end_date'] = endDate?.toString();
    }

    if (updatedAt != null) {
      map['updated_at'] = updatedAt?.toString();
    }
    map['message'] = message;
    map['is_active'] = isActive;
    return map;
  }

  Map<String, dynamic> toAddUpdate() {
    final map = <String, dynamic>{};
    map['merchant'] = merchant;
    map['title'] = title;
    map['type'] = type?.toValue();
    if (startDate != null) {
      map['start_date'] = startDate?.toString();
    }
    if (endDate != null) {
      map['end_date'] = endDate?.toString();
    }
    map['message'] = message;
    map['is_active'] = isActive;
    return map;
  }

  FlashTagAlertModel copyWith({
    String? id,
    String? merchant,
    String? title,
    FlashTagCategory? type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? updatedAt,
    String? message,
    bool? isActive,
  }) {
    return FlashTagAlertModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
    );
  }
}

class FlashTagCategory {
  String _category = "Crawling text";

  FlashTagCategory(String cat) {
    setFlashTag(cat);
  }

  void setFlashTag(String cat) {
    switch (cat) {
      case "Crawling text":
      case "scrollable":
        _category = "Crawling text";
        break;
      case "Pop-up":
      case "popup":
        _category = "Pop-up";
        break;
      default:
        _category = "Crawling text";
    }
  }

  String toString() {
    switch (_category) {
      case "Crawling text":
      case "scrollable":
        return "Crawling text";
      case "Pop-up":
      case "popup":
        return "Pop-up";
      default:
        return "Crawling text";
    }
  }

  String toValue() {
    switch (_category) {
      case "Crawling text":
      case "scrollable":
        return "scrollable";
      case "Pop-up":
      case "popup":
        return "popup";
      default:
        return "scrollable";
    }
  }
}
