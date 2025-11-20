abstract class PostEvent {}

class LoadPost extends PostEvent {}

class CreatePost extends PostEvent {
  final String content;
  final String? imagePath;

  CreatePost({required this.content, required this.imagePath});
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
