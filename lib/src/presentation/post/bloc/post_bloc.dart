import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_infinite_list/src/data/model/post.dart';
import 'package:flutter_bloc_infinite_list/src/presentation/post/bloc/post_event.dart';
import 'package:flutter_bloc_infinite_list/src/presentation/post/bloc/post_state.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);
const _postLimit = 20;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client _httpClient;

  PostBloc({required http.Client httpClient})
      : _httpClient = httpClient,
        super(const PostState()) {
    on<PostFetched>(_onFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final posts = await _fetchPosts(startIndex: state.posts.length);

      if (posts.isEmpty) {
        return emit(state.copyWith(hasReachedMax: true));
      }

      emit(
        state.copyWith(
          status: PostStatus.success,
          posts: [...state.posts, ...posts],
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts({required int startIndex}) async {
    final response = await _httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;

      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;

        return Post(
          id: map['id'] as int,
          title: map['title'] as String,
          body: map['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}
