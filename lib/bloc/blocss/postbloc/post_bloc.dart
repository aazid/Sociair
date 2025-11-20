import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/blocss/postbloc/post_event.dart';
import 'package:ludo/bloc/blocss/postbloc/post_state.dart';
import 'package:ludo/model/PostModel.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  List<PostModel> posts = [];
  final Random _random = Random();

  PostBloc() : super(PostInitial()) {
    on<LoadPost>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<DeletePost>(_onDeletePost);
    on<LikePost>(_onLikePost);
    on<RefreshPosts>(_onRefreshPosts);
  }
  void _onLoadPosts(LoadPost event, Emitter<PostState> emit) async {
    emit(PostLoading());
    await Future.delayed(Duration(milliseconds: 800));

    if (posts.isEmpty) {
      _generateRandomPosts();
    }
    emit(PostLoaded(posts: List.from(posts)));
  }

  void _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    emit(PostLoading());

    final newPost = PostModel(
      author: 'You',
      content: event.content,
      createdAt: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: event.imagePath,
      isLiked: false,
      likes: 0,
    );
    posts.insert(0, newPost);

    await Future.delayed(Duration(milliseconds: 500));
    emit(PostLoaded(posts: List.from(posts)));
  }

  void _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    posts.removeWhere((posts) => posts.id == event.postId);
    emit(PostLoaded(posts: List.from(posts)));
  }

  void _onLikePost(LikePost event, Emitter<PostState> emit) async {
    final postIndex = posts.indexWhere((posts) => posts.id == event.postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      post[postIndex] = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      emit(PostLoaded(posts: List.from(posts)));
    }
  }

  void _onRefreshPosts(RefreshPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    _generateRandomPosts();
    await Future.delayed(Duration(milliseconds: 600));
    emit(PostLoaded(posts: List.from(posts)));
  }

  void _generateRandomPosts() {
    final randomPosts = [
      "Just had an amazing day at the beach! 🏖️",
      "Working on some exciting new projects 💻",
      "Beautiful sunset tonight 🌅",
      "Great coffee and good vibes ☕",
      "Weekend adventures begin! 🚀",
      "Loving this new book I'm reading 📚",
      "Delicious homemade dinner 🍝",
      "Morning workout complete! 💪",
    ];
    final authors = [
      "John Doe",
      "Jane Smith",
      "Alex Johnson",
      "Sarah Wilson",
      "Mike Brown",
    ];
    posts.clear();
    for (int i = 0; i < 5; i++) {
      posts.add(
        PostModel(
          id: (DateTime.now().millisecondsSinceEpoch + i).toString(),
          content: randomPosts[_random.nextInt(randomPosts.length)],
          imagePath: _random.nextBool()
              ? 'assets/sample_${_random.nextInt(3) + 1}.jpg'
              : null,
          createdAt: DateTime.now().subtract(
            Duration(hours: _random.nextInt(24)),
          ),
          likes: _random.nextInt(50),
          isLiked: _random.nextBool(),
          author: authors[_random.nextInt(authors.length)],
        ),
      );
    }
  }
}
