import 'package:flutter/cupertino.dart';

extension EdgeInsetsAlias on num {
  EdgeInsets get all => EdgeInsets.all(this / 1);
  EdgeInsets get lr => EdgeInsets.symmetric(horizontal: this / 1);
  EdgeInsets get tb => EdgeInsets.symmetric(vertical: this / 1);
  EdgeInsets get ol => EdgeInsets.only(left: this / 1);
  EdgeInsets get or => EdgeInsets.only(left: this / 1);
  EdgeInsets get lb => EdgeInsets.only(left: this / 1, bottom: this / 1);
  EdgeInsets get lt => EdgeInsets.only(left: this / 1, top: this / 1);
  EdgeInsets get rt => EdgeInsets.only(right: this / 1, top: this / 1);
  EdgeInsets get et =>
      EdgeInsets.only(left: this / 1, right: this / 1, bottom: this / 1);
  EdgeInsets get eb =>
      EdgeInsets.only(left: this / 1, right: this / 1, top: this / 1);
  EdgeInsets get el =>
      EdgeInsets.only(right: this / 1, top: this / 1, bottom: this / 1);
  EdgeInsets get er =>
      EdgeInsets.only(left: this / 1, top: this / 1, bottom: this / 1);
}

const k8dp = 16.0;
const k6dp = 12.0;
const k4dp = 8.0;
const k2dp = 4.0;
const k0dp = 0.0;
