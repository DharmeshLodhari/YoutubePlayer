class JobModel {
  String? id;
  List<String>? tags;
  List<Pictures>? pictures;
  Video? video;
  Category? category;
  String? ownerAvatar;
  String? ownerName;
  int? applicantsCount;
  String? activeListing;
  String? title;
  int? pay;
  String? status;
  String? owner;
  bool? isListed;
  bool? isOnline;
  List<dynamic>? applicants;
  String? assignee;
  String? assigneeAvatar;
  String? description;
  String? dueDate;
  String? creationDate;
  // String? location;
  String? city;
  String? state;
  bool? isNegotiable;
  bool? isVerified;
  String? currency;
  int? transactionId;
  String? referenceNumber;

  JobModel({
    this.id,
    this.tags,
    this.pictures,
    this.video,
    this.category,
    this.ownerAvatar,
    this.ownerName,
    this.applicantsCount,
    this.activeListing,
    this.title,
    this.pay,
    this.status,
    this.owner,
    this.isListed,
    this.isOnline,
    this.applicants,
    this.assignee,
    this.assigneeAvatar,
    this.description,
    this.dueDate,
    this.creationDate,
    // this.location,
    this.city,
    this.state,
    this.isVerified,
    this.isNegotiable,
    this.transactionId,
    this.currency,
    this.referenceNumber,
  });

  JobModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'].cast<String>();
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(Pictures.fromJson(v));
      });
    }
    video = json['video'] != null ? Video.fromJson(json['video']) : null;
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    ownerAvatar = json['owner_avatar'];
    ownerName = json['owner_name'];
    applicantsCount = json['applicants_count'];
    activeListing = json['active_listing'];
    title = json['title'];
    pay = json['pay'];
    status = json['status'];
    owner = json['owner'];
    isListed = json['is_listed'];
    isOnline = json['is_online'];
    isVerified = json['is_verified'];
    applicants = json['applicants'] == null ? [] : json['applicants'];
    assignee = json['assignee'];
    assigneeAvatar = json['assignee_avatar'];
    description = json['description'];
    dueDate = json['due_date'];
    referenceNumber = json['reference_number'];
    creationDate = json['creation_date'];
    // location = json['location'];
    city = json['city'];
    state = json['state'];
    transactionId = json['transaction_id'];
    isNegotiable =
        json.containsKey('is_negotiable') ? json['is_negotiable'] : false;
    currency = json.containsKey('currency') ? json['currency'] : 'NGN';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tags'] = tags;
    if (pictures != null) {
      data['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }
    if (video != null) {
      data['video'] = video!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['owner_avatar'] = ownerAvatar;
    data['owner_name'] = ownerName;
    data['applicants_count'] = applicantsCount;
    data['active_listing'] = activeListing;
    data['title'] = title;
    data['pay'] = pay;
    data['status'] = status;
    data['owner'] = owner;
    data['is_listed'] = isListed;
    data['is_online'] = isOnline;
    data['applicants'] = applicants;
    data['assignee'] = assignee;
    data['assignee_avatar'] = assigneeAvatar;
    data['description'] = description;
    data['due_date'] = dueDate;
    data['creation_date'] = creationDate;
    data['reference_number'] = referenceNumber;
    // data['location'] = this.location;
    data['city'] = city;
    data['state'] = state;
    data['transaction_id'] = transactionId;
    data['is_verified'] = isVerified;
    return data;
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    // debugPrint("${this.serverImages}");
    for (var data in pictures!) {
      if (data.image == imageUrl) {
        return data.id.toString();
      }
    }
    return "";
  }
}

class Pictures {
  String? id;
  String? image;
  String? caption;

  Pictures({this.id, this.image, this.caption});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['caption'] = caption;
    return data;
  }
}

class Category {
  String? slug;
  String? image;
  String? name;

  Category({this.slug, this.image, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    slug = json['slug'];
    image = json['image'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['slug'] = slug;
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}

class Video {
  String? id;
  String? file;
  dynamic imagePoster;
  dynamic caption;

  Video({this.id, this.file, this.imagePoster, this.caption});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
    imagePoster = json['image_poster'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['file'] = file;
    data['image_poster'] = imagePoster;
    data['caption'] = caption;
    return data;
  }
}
