import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InstagramPost {
  final String id;
  final String caption;
  final String mediaUrl;
  final String mediaType; // 'IMAGE' or 'VIDEO'
  final DateTime timestamp;
  final int likes;
  final String? permalink;

  InstagramPost({
    required this.id,
    required this.caption,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
    required this.likes,
    this.permalink,
  });

  factory InstagramPost.fromJson(Map<String, dynamic> json) {
    return InstagramPost(
      id: json['id'] ?? '',
      caption: json['caption'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'IMAGE',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      likes: json['like_count'] ?? 0,
      permalink: json['permalink'],
    );
  }
}

class InstagramService {
  // Instagram Graph API Configuration
  // Replace these with your actual credentials from Meta Business Manager
  // See: https://developers.facebook.com/docs/instagram-graph-api/getting-started
  static const String _instagramBusinessAccountId = 'YOUR_INSTAGRAM_BUSINESS_ACCOUNT_ID';
  static const String _accessToken = 'YOUR_INSTAGRAM_ACCESS_TOKEN';

  /// Fetch real Instagram posts from FBLA's Instagram Business Account
  /// 
  /// To get real posts:
  /// 1. Go to https://business.facebook.com/
  /// 2. Set up your FBLA Instagram Business Account
  /// 3. Get your Business Account ID from Settings
  /// 4. Generate a long-lived access token (36 months) in App Roles > Test Users
  /// 5. Replace the constants above with your real values
  /// 
  /// Required API fields: id, caption, media_type, media_url, timestamp, like_count, permalink
  static Future<List<InstagramPost>> fetchInstagramPosts() async {
    try {
      if (_instagramBusinessAccountId == 'YOUR_INSTAGRAM_BUSINESS_ACCOUNT_ID' ||
          _accessToken == 'YOUR_INSTAGRAM_ACCESS_TOKEN') {
        debugPrint('Instagram credentials not configured. Using mock data.');
        return _getMockInstagramPosts();
      }

      final url = Uri.parse(
        'https://graph.instagram.com/$_instagramBusinessAccountId/media'
        '?fields=id,caption,media_type,media_url,timestamp,like_count,permalink'
        '&access_token=$_accessToken',
      );

      debugPrint('Fetching Instagram posts from: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final posts = (data['data'] as List<dynamic>?)
            ?.map((post) => InstagramPost.fromJson(post as Map<String, dynamic>))
            .toList() ?? [];
        debugPrint('Successfully fetched ${posts.length} Instagram posts');
        return posts;
      } else {
        debugPrint('Failed to fetch Instagram posts: ${response.statusCode} - ${response.body}');
        return _getMockInstagramPosts();
      }
    } catch (e) {
      debugPrint('Error fetching Instagram posts: $e');
      return _getMockInstagramPosts();
    }
  }

  /// Mock Instagram posts for development/testing
  static List<InstagramPost> _getMockInstagramPosts() {
    return [
      InstagramPost(
        id: '1',
        caption: 'FBLA is excited to announce the 2026 NLC T-Shirt Design Contest, and we\'re inviting chapters to submit original designs inspired by this year\'s national theme!',
        mediaUrl: 'assets/fbla_logo.png',
        mediaType: 'IMAGE',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likes: 312,
        permalink: 'https://www.instagram.com/fbla_national/',
      ),
      InstagramPost(
        id: '2',
        caption: 'Hey FBLA seniors! Can you believe that graduation is quickly approaching? Show off your FBLA pride at graduation and order official FBLA cords and stoles at the FBLA Shop.',
        mediaUrl: 'assets/fbla_logo.png',
        mediaType: 'IMAGE',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        likes: 245,
        permalink: 'https://www.instagram.com/fbla_national/',
      ),
      InstagramPost(
        id: '3',
        caption: '🔔 The latest FBLA at the Bell Episode is live! Emma and Jaden break down the difference between dupes and counterfeits — and why the line between "inspired by" and "copied" isn\'t always clear.',
        mediaUrl: 'assets/fbla_logo.png',
        mediaType: 'IMAGE',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        likes: 198,
        permalink: 'https://www.instagram.com/fbla_national/',
      ),
    ];
  }
}

