import 'package:get/get.dart';

class Responsive {
  static double get screenWidth => Get.width;
  static double get screenHeight => Get.height;

  static double getWidth(double percentage) {
    return Get.width * (percentage / 100);
  }

  static double getHeight(double percentage) {
    return Get.height * (percentage / 100);
  }

  // Spacing utilities
  static double get spacing4 => getWidth(1);
  static double get spacing8 => getWidth(2);
  static double get spacing12 => getWidth(3);
  static double get spacing16 => getWidth(4);
  static double get spacing20 => getWidth(5);
  static double get spacing24 => getWidth(6);
  static double get spacing32 => getWidth(8);

  // Font sizes
  static double get fontSize12 => getWidth(3);
  static double get fontSize14 => getWidth(3.5);
  static double get fontSize16 => getWidth(4);
  static double get fontSize18 => getWidth(4.5);
  static double get fontSize20 => getWidth(5);
  static double get fontSize24 => getWidth(6);

  // Border radius
  static double get radius8 => getWidth(2);
  static double get radius12 => getWidth(3);
  static double get radius16 => getWidth(4);

  // Icon sizes
  static double get iconSize20 => getWidth(5);
  static double get iconSize24 => getWidth(6);
  static double get iconSize28 => getWidth(7);
}
