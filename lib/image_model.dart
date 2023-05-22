class ImageModel {
  final String id;
  final String title;
  final String url;

  ImageModel({required this.id, required this.title, required this.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }
}
