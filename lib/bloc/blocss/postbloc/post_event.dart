abstract class PostEvent {}

class LoadPost extends PostEvent {}

class CreatePost extends PostEvent {
  final String content;
  final String? imagePath;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  CreatePost({
    required this.content,
    this.imagePath,
    this.locationName,
    this.latitude,
    this.longitude,
  });
}

class DeletePost extends PostEvent {
  final String postId;
  DeletePost({required this.postId});
}

class LikePost extends PostEvent {
  final String postId;
  LikePost({required this.postId});
}

class RefreshPosts extends PostEvent {}
