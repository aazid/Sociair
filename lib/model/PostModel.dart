class PostModel {
  final String id;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final String author;

  PostModel({
    required this.author,
    required this.content,
    required this.createdAt,
    required this.id,
    required this.imagePath,
    required this.isLiked,
    required this.likes,
  });

  PostModel copyWith({
    String? id,
    String? content,
    String? imagePath,
    DateTime? createdAt,
    String? author,
    int? likes,
    bool? isLiked,
  }) {
    return PostModel(
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
    );
  }

  void operator []=(int other, PostModel value) {}
}
