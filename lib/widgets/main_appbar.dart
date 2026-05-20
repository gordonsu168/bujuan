import 'package:bujuan_music/common/values/app_images.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons_pro/hugeicons.dart';

AppBar mainAppBar({Widget? leading, String? title, List<Widget>? actions}) {
  return AppBar(
    leading: leading ??
        IconButton(
          onPressed: () {},
          icon: Image.asset(AppImages.logo, width: 35.w, height: 35.w),
        ),
    title: Text(
      title ?? 'BuJuan',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    leadingWidth: 55.w,
    actions: [
      ...?actions,
      Consumer(
        builder: (context, ref, child) {
          return IconButton(
            onPressed: () {
              bool isDark = ref.read(themeModeProvider) == ThemeMode.dark;
              ref
                  .read(themeModeProvider.notifier)
                  .setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
            },
            icon: Icon(HugeIconsSolid.search01),
          );
        },
      ),
    ],
  );
}
