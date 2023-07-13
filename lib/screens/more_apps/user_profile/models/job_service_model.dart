class JobServiceToChatModel {
  String? id;
  List<dynamic>? tags;
  List<Picture>? pictures;
  dynamic video;
  Category? category;
  String? ownerName;
  String? ownerAvatar;
  int? applicantsCount;
  String? activeListing;
  String? title;
  int? pay;
  String? currency;
  String? status;
  String? owner;
  bool? isListed;
  bool? isNegotiable;
  dynamic applicants;
  dynamic assignee;
  String? description;
  DateTime? dueDate;
  String? creationDate;
  String? location;

  JobServiceToChatModel({
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
    this.currency,
    this.status,
    this.owner,
    this.isListed,
    this.isNegotiable,
    this.applicants,
    this.assignee,
    this.description,
    this.dueDate,
    this.creationDate,
    this.location,
  });

  factory JobServiceToChatModel.fromJson(Map<String, dynamic> json) {
    JobServiceToChatModel jobModel = JobServiceToChatModel(
        id: json['id'],
        tags: json['tags'],
        pictures: json['pictures'] != null
            ? (json['pictures'] as List)
                .map((i) => Picture.fromJson(i))
                .toList()
            : [],

        ownerAvatar: json['owner_avatar'],
        ownerName: json['owner_name'],
        applicantsCount: json['applicant_count'],
        activeListing: json['active_listing'],
        title: json['title'],
        pay: json['pay'],
        currency: json['currency'],
        status: json['status'],
        owner: json['owner'],
        isListed: json['is_listed'],
        isNegotiable: json['is_negotiable'],
        description: json['description'],
        dueDate: json['due_dated'],
        creationDate: json['creation_date'] ,
        location: json['location']);

    if (json['category'] != null) {
      jobModel.category = Category.fromJson(json['category']);
    }

    return jobModel;
  }
}

class Category {
  String slug;
  String image;
  String name;

  Category({
    required this.slug,
    required this.image,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'],
      image: json['image'],
      name: json['name'],
    );
  }
}

class Picture {
  String id;
  String image;
  String caption;

  Picture({
    required this.id,
    required this.image,
    required this.caption,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'],
      image: json['image'],
      caption: json['caption'],
    );
  }
}
