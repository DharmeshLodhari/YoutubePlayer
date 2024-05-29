import 'package:Slydo/screens/more_apps/taxi/model/place.dart';
import 'package:Slydo/utils/extensions.dart';

class DiscountModel {
  String? id;
  DiscountTagCategory? type;
  String? name;
  String? merchant;
  bool isActive = true;
  int? value;
  int? productCount;
  int? serviceCount;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? onlyFrom;
  DateTime? onlyTo;
  DateTime? createdAt;
  DateTime? updatedAt;
  Consumables? consumables;
  String? poster;

  DiscountModel({
    this.id,
    this.type,
    this.name,
    this.merchant,
    this.isActive = true,
    this.value,
    this.productCount,
    this.serviceCount,
    this.startDate,
    this.endDate,
    this.onlyFrom,
    this.onlyTo,
    this.createdAt,
    this.updatedAt,
    this.consumables,
    this.poster,
  }) {
    type ??= DiscountTagCategory("Percentage %");
  }

  DiscountModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = DiscountTagCategory(json['type']);
    name = json['name'];
    merchant = json['merchant'];
    isActive = json['is_active'] != null ? json['is_active'] as bool : true;
    value = json['value'];
    productCount = json['product_count'];
    serviceCount = json['service_count'];
    if (json['start_date'] != null) {
      final List<int> parse = json['start_date']
          .toString()
          .split("-")
          .toList()
          .map((e) => int.parse(e))
          .toList();
      if (parse != null) {
        startDate = DateTime(parse[0], parse[1], parse[2]);
      }
    }

    if (json['end_date'] != null) {
      final List<int> parse = json['end_date']
          .toString()
          .split("-")
          .toList()
          .map((e) => int.parse(e))
          .toList();
      if (parse != null) {
        endDate = DateTime(parse[0], parse[1], parse[2]);
      }
    }

    if (json['only_from'] != null) {
      final List<int> parse = json['only_from']
          .toString()
          .split(":")
          .toList()
          .map((e) => int.parse(e))
          .toList();
      if (parse != null) {
        onlyFrom = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, parse[0], parse[1]);
      }
    }
    if (json['only_to'] != null) {
      final List<int> parse = json['only_to']
          .toString()
          .split(":")
          .toList()
          .map((e) => int.parse(e))
          .toList();
      if (parse != null) {
        onlyTo = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, parse[0], parse[1]);
      }
    }

    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at']);
    }

    if (json['updated_at'] != null) {
      updatedAt = DateTime.parse(json['updated_at']);
    }
    consumables = json['consumables'] != null
        ? new Consumables.fromJson(json['consumables'])
        : null;
    poster = json['poster'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    map['type'] = type?.toValue();
    data['name'] = this.name;
    data['merchant'] = this.merchant;
    data['is_active'] = this.isActive;
    data['value'] = this.value;
    data['product_count'] = this.productCount;
    data['service_count'] = this.serviceCount;
    if (startDate != null) {
      map['start_date'] = startDate?.toString();
    }

    if (endDate != null) {
      map['end_date'] = endDate?.toString();
    }

    if (updatedAt != null) {
      map['updated_at'] = updatedAt?.toString();
    }

    if (createdAt != null) {
      map['created_at'] = createdAt?.toString();
    }

    data['only_from'] = this.onlyFrom;
    data['only_to'] = this.onlyTo;
    data['created_at'] = this.createdAt;
    if (this.consumables != null) {
      data['consumables'] = this.consumables!.toJson();
    }
    data['poster'] = this.poster;
    return data;
  }

  Map<String, dynamic> toAddUpdate() {
    final map = <String, dynamic>{};
    map['type'] = type?.toValue();
    map['value'] = value;
    map['name'] = name;
    map['is_active'] = isActive;
    if (startDate != null) {
      map['start_date'] =
          startDate?.toDateFormatString(dateFormat: "yyyy-MM-dd").toString();
    }
    if (endDate != null) {
      map['end_date'] =
          endDate?.toDateFormatString(dateFormat: "yyyy-MM-dd").toString();
    }
    if (onlyFrom != null) {
      map['only_from'] = onlyFrom?.toDateFormatString(dateFormat: "hh:mm");
    }
    if (onlyTo != null) {
      map['only_to'] = onlyTo?.toDateFormatString(dateFormat: "hh:mm");
    }
    if (consumables != null) {
      map['consumables'] = consumables?.toJson() ?? {};
    }
    // map['poster'] = poster;

    return map;
  }

  DiscountModel copyWith({
    DiscountTagCategory? type,
    int? value,
    int? productCount,
    int? serviceCount,
    bool? isActive,
    String? name,
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? onlyFrom,
    DateTime? onlyTo,
    Consumables? consumables,
    String? poster,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      productCount: productCount ?? this.productCount,
      serviceCount: serviceCount ?? this.serviceCount,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      onlyFrom: onlyFrom ?? this.onlyFrom,
      onlyTo: onlyTo ?? this.onlyTo,
      consumables: consumables ?? this.consumables,
      poster: poster ?? this.poster,
    );
  }

  void addProductsToDiscount(List<String?> products) {
    consumables ??= Consumables(product: []);

    final List<String> data = [];

    for (String? id in products) {
      if (id != null) {
        data.add(id);
      }
    }

    consumables?.product = data;
  }

  void addServicesToDiscount(List<String?> services) {
    consumables ??= Consumables(service: []);

    final List<String> data = [];

    for (String? id in services) {
      if (id != null) {
        data.add(id);
      }
    }

    consumables?.service = data;
  }
}

class DiscountTagCategory {
  String _category = "Percentage %";

  DiscountTagCategory(String cat) {
    setFlashTag(cat);
  }

  void setFlashTag(String cat) {
    switch (cat) {
      case "Percentage %":
      case "percentage":
        _category = "Percentage %";
        break;
      case "Amount (₦)":
      case "price":
        _category = "Amount (₦)";
        break;
      default:
        _category = "Percentage %";
    }
  }

  String toString() {
    switch (_category) {
      case "Percentage %":
      case "percentage":
        return "Percentage %";
      case "Amount (₦)":
      case "price":
        return "Amount (₦)";
      default:
        return "Percentage %";
    }
  }

  String toValue() {
    switch (_category) {
      case "Percentage %":
      case "percentage":
        return "percentage";
      case "Amount (₦)":
      case "price":
        return "price";
      default:
        return "percentage";
    }
  }
}

class Consumables {
  List<String>? product;
  List<String>? service;

  Consumables({
    this.product,
    this.service,
  });

  Consumables.fromJson(Map<String, dynamic> json) {
    product = json['Product'].cast<String>();
    service = json['Service'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.product != null) {
      data['Product'] = this.product;
    }
    if (this.service != null) {
      data['Service'] = this.service;
    }
    return data;
  }
}
