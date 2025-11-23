// import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ludo/bloc/blocss/postbloc/post_bloc.dart';
import 'package:ludo/bloc/blocss/postbloc/post_event.dart';
import 'package:ludo/bloc/blocss/postbloc/post_state.dart';
import 'package:ludo/screens/CreatePostScreen.dart';
import 'package:ludo/widgets/PostCard.dart';

class PostScreens extends StatelessWidget {
  const PostScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Posts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0.5,
        // actions: [
        //   IconButton(
        //     onPressed: () => context.read<PostBloc>().add(RefreshPosts()),
        //     icon: Icon(Icons.refresh, color: Colors.white),
        //   ),
        // ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading || state is PostInitial) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue[700]),
            );
          }
          if (state is Error) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.error, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<PostBloc>().add(LoadPost()),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PostLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 64.sp, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'No Posts Yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Create your First Post',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostCard(post: post);
                },
              ),
              onRefresh: () async {
                context.read<PostBloc>().add(RefreshPosts());
              },
            );
          }
          return SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
