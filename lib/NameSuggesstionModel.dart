class NameSuggesstionModel {
  String name;
  String profileImage;

  NameSuggesstionModel({required this.name, required this.profileImage});

  factory NameSuggesstionModel.fromJson(Map<String, dynamic> json) {
    return NameSuggesstionModel(
      name: json['name'] as String,
      profileImage: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['photoUrl'] = this.profileImage;
    return data;
  }
}
