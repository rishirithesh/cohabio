import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class CommunitiesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  CommunitiesNotifier() : super(const AsyncValue.loading()) {
    fetchCommunities();
  }

  Future<void> fetchCommunities({String? category}) async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get("/communities/", queryParameters: category != null && category != "All" ? {"category": category.toLowerCase()} : null);
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await apiClient.post("/communities/$communityId/join");
      if (response.statusCode == 200) {
        // Refresh local list
        await fetchCommunities();
        return true;
      }
    } catch (e) {
      print("Error joining community: $e");
    }
    return false;
  }

  Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await apiClient.post("/communities/$communityId/leave");
      if (response.statusCode == 200) {
        await fetchCommunities();
        return true;
      }
    } catch (e) {
      print("Error leaving community: $e");
    }
    return false;
  }
}

final communitiesProvider = StateNotifierProvider<CommunitiesNotifier, AsyncValue<List<dynamic>>>((ref) {
  return CommunitiesNotifier();
});

class CommunityPostsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final String communityId;
  CommunityPostsNotifier(this.communityId) : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get("/communities/$communityId/posts");
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> createPost(String content) async {
    try {
      final response = await apiClient.post(
        "/communities/$communityId/posts",
        data: {"content": content, "media_urls": []},
      );
      if (response.statusCode == 200) {
        await fetchPosts();
        return true;
      }
    } catch (e) {
      print("Error creating post: $e");
    }
    return false;
  }

  Future<void> toggleLike(String postId) async {
    try {
      final response = await apiClient.post("/communities/posts/$postId/like");
      if (response.statusCode == 200) {
        // Update local state directly to feel fast
        if (state.hasValue) {
          final updated = state.value!.map((post) {
            if (post["id"] == postId) {
              final isLiked = response.data["status"] == "liked";
              return {
                ...post,
                "likes_count": response.data["likes_count"],
                "is_liked_by_me": isLiked,
              };
            }
            return post;
          }).toList();
          state = AsyncValue.data(updated);
        }
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }
}

final communityPostsProvider = StateNotifierProvider.family<CommunityPostsNotifier, AsyncValue<List<dynamic>>, String>((ref, communityId) {
  return CommunityPostsNotifier(communityId);
});
