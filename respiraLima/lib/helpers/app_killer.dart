
  import 'dart:io';

import 'package:app4/helpers/helpers.dart';
import 'package:flutter/services.dart';

void getOutOfApp() {

      if (isIOS) {

        try {
          exit(0); 
        } catch (e) {
          SystemNavigator.pop(); // for IOS, not true this, you can make comment this :)
        }

      } else {

        try {
          SystemNavigator.pop(); // sometimes it cant exit app  
        } catch (e) {
          exit(0); // so i am giving crash to app ... sad :(
        }

      }
    }