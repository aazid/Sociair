class PostModel {
  final String id;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final String author;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  PostModel({
    required this.author,
    required this.content,
    required this.createdAt,
    required this.id,
    this.imagePath,
    required this.isLiked,
    required this.likes,
    this.latitude,
    this.locationName,
    this.longitude,
  });

  PostModel copyWith({
    String? id,
    String? content,
    String? imagePath,
    DateTime? createdAt,
    String? author,
    int? likes,
    bool? isLiked,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return PostModel(
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      locationName: locationName ?? this.locationName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }
}
