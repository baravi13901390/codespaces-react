import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data'; // ignore_for_file: unnecessary_import
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ---- بخش‌های برنامه (هر فایل با «part of» به این فایل وصل است) ----
part 'home_screen.dart';
part 'cube_story_bar.dart';
part 'story_viewer.dart';
part 'comments_share.dart';
part 'search_explore.dart';
part 'feed_post_card.dart';
part 'leaderboard_reels.dart';
part 'create_post_screen.dart';
part 'profile_screen.dart';
part 'judge_center.dart';
part 'notifications.dart';
part 'messages.dart';
part 'settings_screen.dart';
part 'post_store.dart';
part 'my_works.dart';
part 'login_screen.dart';
part 'persist.dart';
part 'collections.dart';
part 'social_store.dart';
part 'highlights.dart';
part 'archive_and_feed.dart';
part 'compose_screen.dart';
part 'close_friends_tags.dart';
part 'tournament_screen.dart';
part 'post_widgets.dart';

part 'category_store.dart';
part 'share_sheet.dart';
part 'feed_items.dart';

void main() {
  bootstrap();
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class BaraviTalentApp extends StatelessWidget {
  const BaraviTalentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Baravi Talent Hub',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF0055),
          surface: Color(0xFF18181F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14141A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      home: const LoginScreen2(),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Persist.load();
  await CollectionStore.I.load();
  await SocialStore.I.load();
  await ProfileCubeImages.I.load();
  await CategoryStore.I.load();
  await AppPrefs.I.load();
  // بازیابی نمره‌های ثبت‌شده از حافظه‌ی دائمی
  try {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final String? raw = p.getString('baravi_myvotes');
    if (raw != null) {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> e in m.entries) {
        kMyVotes[e.key] = (e.value as num).toInt();
      }
    }
  } catch (_) {}
  Persist.start();
  runApp(const BaraviTalentApp());
}
