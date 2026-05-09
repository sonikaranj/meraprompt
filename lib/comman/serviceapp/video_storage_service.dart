import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class StoredVideoData {
  final String videoId;
  final String title;
  final String description;
  final String channelName;
  final String thumbnailPath; // Local file path
  final String videoPath; // Local file path (agar download kiya ho)
  final DateTime savedAt;
  final String youtubeUrl;

  StoredVideoData({
    required this.videoId,
    required this.title,
    required this.description,
    required this.channelName,
    required this.thumbnailPath,
    required this.videoPath,
    required this.savedAt,
    required this.youtubeUrl,
  });

  // JSON convert karne ke liye
  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'description': description,
    'channelName': channelName,
    'thumbnailPath': thumbnailPath,
    'videoPath': videoPath,
    'savedAt': savedAt.toIso8601String(),
    'youtubeUrl': youtubeUrl,
  };

  factory StoredVideoData.fromJson(Map<String, dynamic> json) {
    return StoredVideoData(
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      channelName: json['channelName'],
      thumbnailPath: json['thumbnailPath'],
      videoPath: json['videoPath'],
      savedAt: DateTime.parse(json['savedAt']),
      youtubeUrl: json['youtubeUrl'],
    );
  }
}

class VideoStorageService {
  static const String _videosKey = 'stored_videos_data';
  static final Dio _dio = Dio();

  // 📁 Application documents directory milao
  static Future<Directory> _getVideoDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${dir.path}/downloaded_videos');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return videoDir;
  }

  // 🖼️ Thumbnail download aur save karo
  static Future<String> _downloadThumbnail(String videoId) async {
    try {
      final dir = await _getVideoDirectory();
      final thumbnailUrl =
          'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      final thumbnailPath = '${dir.path}/thumb_$videoId.jpg';

      await _dio.download(thumbnailUrl, thumbnailPath);
      print('✅ Thumbnail downloaded: $thumbnailPath');
      return thumbnailPath;
    } catch (e) {
      print('❌ Thumbnail download failed: $e');
      return '';
    }
  }

  // 🎥 Video download karo (YouTube se direct nahi hota,
  // par agar aapke paas HLS link ho to kar sakte ho)
  static Future<String> _downloadVideo(String youtubeUrl) async {
    try {
      // NOTE: YouTube direct download nahi karta copyright ke wajah se
      // Aap instaloader ya youtube-dl use kar sakte ho backend pe
      print('⚠️ Direct YouTube download nahi possible');
      return ''; // Return empty for now
    } catch (e) {
      print('❌ Video download failed: $e');
      return '';
    }
  }

  // 💾 Video data ko local storage me save karo
  static Future<void> saveVideoData({
    required String videoId,
    required String title,
    required String description,
    required String channelName,
    required String youtubeUrl,
    String? videoPath,
  }) async {
    try {
      // 1️⃣ Thumbnail download karo
      final thumbnailPath = await _downloadThumbnail(videoId);

      // 2️⃣ Video data object banao
      final videoData = StoredVideoData(
        videoId: videoId,
        title: title,
        description: description,
        channelName: channelName,
        thumbnailPath: thumbnailPath,
        videoPath: videoPath ?? '',
        savedAt: DateTime.now(),
        youtubeUrl: youtubeUrl,
      );

      // 3️⃣ SharedPreferences me save karo
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_videosKey) ?? '[]';
      final List<dynamic> videos = jsonDecode(existingData);

      // Check karo duplicate entry nahi ho
      videos.removeWhere((v) => v['videoId'] == videoId);
      videos.add(videoData.toJson());

      await prefs.setString(_videosKey, jsonEncode(videos));
      print('✅ Video data saved: $title');
    } catch (e) {
      print('❌ Error saving video: $e');
    }
  }

  // 📂 Sab saved videos retrieve karo
  static Future<List<StoredVideoData>> getAllSavedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_videosKey) ?? '[]';
      final List<dynamic> videos = jsonDecode(data);

      return videos
          .map((v) => StoredVideoData.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading videos: $e');
      return [];
    }
  }

  // 🗑️ Video delete karo
  static Future<void> deleteVideo(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_videosKey) ?? '[]';
      final List<dynamic> videos = jsonDecode(data);

      final videoToDelete = videos.firstWhere(
            (v) => v['videoId'] == videoId,
        orElse: () => null,
      );

      if (videoToDelete != null) {
        // 🗑️ Local files delete karo
        if (videoToDelete['thumbnailPath'].isNotEmpty) {
          final file = File(videoToDelete['thumbnailPath']);
          if (await file.exists()) {
            await file.delete();
          }
        }

        if (videoToDelete['videoPath'].isNotEmpty) {
          final file = File(videoToDelete['videoPath']);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // 🗑️ SharedPreferences se remove karo
        videos.removeWhere((v) => v['videoId'] == videoId);
        await prefs.setString(_videosKey, jsonEncode(videos));
        print('✅ Video deleted: $videoId');
      }
    } catch (e) {
      print('❌ Error deleting video: $e');
    }
  }


// 🔍 Specific video find karo
  static Future<StoredVideoData?> getVideoById(String videoId) async {
    try {
      final videos = await getAllSavedVideos();
      return videos.firstWhere(
            (v) => v.videoId == videoId,
      );
    } catch (e) {
      print('❌ Error finding video: $e');
      return null; // ✅ Return null if not found
    }
  }
}