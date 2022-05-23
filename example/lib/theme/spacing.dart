import 'package:flutter/cupertino.dart';

extension EdgeInsetsAlias on double {
  EdgeInsets get all => EdgeInsets.all(this);
  EdgeInsets get lr => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get tb => EdgeInsets.symmetric(vertical: this);
  EdgeInsets get ol => EdgeInsets.only(left: this);
  EdgeInsets get or => EdgeInsets.only(left: this);
  EdgeInsets get lb => EdgeInsets.only(left: this, bottom: this);
  EdgeInsets get lt => EdgeInsets.only(left: this, top: this);
  EdgeInsets get rt => EdgeInsets.only(right: this, top: this);
  EdgeInsets get et => EdgeInsets.only(left: this, right: this, bottom: this);
  EdgeInsets get eb => EdgeInsets.only(left: this, right: this, top: this);
  EdgeInsets get el => EdgeInsets.only(right: this, top: this, bottom: this);
  EdgeInsets get er => EdgeInsets.only(left: this, top: this, bottom: this);
}

const k8dp = 16.0;
const k6dp = 12.0;
const k4dp = 8.0;
const k2dp = 4.0;
const k0dp = 0.0;
