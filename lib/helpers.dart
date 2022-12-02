// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

List<int> column1 = [0, 11, 22, 33, 44, 55, 66, 77];
List<int> column2 = [1, 12, 23, 34, 45, 56, 67, 78];
List<int> column3 = [2, 13, 24, 35, 46, 57, 68, 79];
List<int> column4 = [3, 14, 25, 36, 47, 58, 69, 80];
List<int> column5 = [4, 15, 26, 37, 48, 59, 70, 81];
List<int> column6 = [5, 16, 27, 38, 49, 60, 71, 82];
List<int> column7 = [6, 17, 28, 39, 50, 61, 72, 83];
List<int> column8 = [7, 18, 29, 40, 51, 62, 73, 84];
List<int> column9 = [8, 19, 30, 41, 52, 63, 74, 85];
List<int> column10 = [9, 20, 31, 42, 53, 64, 75, 86];
List<int> column11 = [10, 21, 32, 43, 54, 65, 76, 87];


// It's a simple sleeping animation, about the peak of my artistic talent if you ask me
bool SleepAnimation(index, frameNum) {
  if (frameNum % 2 == 1) {
    if (index == 58 || index == 59) {
      return true;
    }
  }
  if (index == 63) {
    return true;
  }
  if (index == 74 || index == 75) {
    return true;
  }
  if (index >= 68 && index <= 71) {
    return true;
  }
  if (index >= 79 && index <= 86) {
    return true;
  }
  return false;
}

// OK this is a really bad name but don't worry about it
bool Dead(index) {
  if (index == 63) {
    return true;
  }
  if (index == 74 || index == 75) {
    return true;
  }
  if (index >= 68 && index <= 71) {
    return true;
  }
  if (index >= 79 && index <= 86) {
    return true;
  }
  return false;
}

// OK this is definitely not a great solution here, but
// it works and I'm too mentally tired to figure out the proper solution
bool ShowerAnimation(index, animationFrame) {
  if (animationFrame == 0) {
    if (column11.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 1) {
    if (column10.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 2) {
    if (column9.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 3) {
    if (column8.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 4) {
    if (column7.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 5) {
    if (column6.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 6) {
    if (column5.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 7) {
    if (column4.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 8) {
    if (column3.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 9) {
    if (column2.contains(index)) {
      return true;
    }
  }
  if (animationFrame == 10) {
    if (column1.contains(index)) {
      return true;
    }
  }

  return false;
}

// Again the animations are hardcoded, but that's on me for not
// wanting to use a sprite and only using gridview.builder
bool IdleAnimation(index, frameNum) {
  if (frameNum % 2 == 0) {
    if (index == 8 || index == 9) {
      return true;
    }
    if (index >= 14 && index <= 16) {
      return true;
    }
    if (index == 18 || index == 19) {
      return true;
    }
    if (index == 24) {
      return false;
    }
    if (index > 24 && index <= 29) {
      return true;
    }
    if (index == 38 || index == 39) {
      return true;
    }
    if (index == 49 || index == 50) {
      return true;
    }
    if (index >= 60 && index <= 61) {
      return true;
    }
    if (index == 70 || index == 73) {
      return true;
    }
    if (index == 81 || index == 84) {
      return true;
    }
  }
  if (frameNum % 2 == 1) {
    if (index >= 13 && index <= 15) {
      return true;
    }
    if (index == 23) {
      return false;
    }
    if (index > 23 && index <= 31) {
      return true;
    }
    if (index >= 37 && index <= 39) {
      return true;
    }
    if (index == 48 || index == 49) {
      return true;
    }
    if (index >= 59 && index <= 60) {
      return true;
    }
    if (index == 69 || index == 72) {
      return true;
    }
    if (index == 81 || index == 84) {
      return true;
    }
  }

  return false;
}

// Determines the color of the various status bars
// Color refers to urgency of the stat
// Green > Amber > Orange > Red
  Color ProgressBarColor(value) {
    if (value > 80) {
      return Colors.green;
    } else if (value > 60) {
      return Colors.amberAccent;
    } else if (value > 40) {
      return Colors.orange;
    }
    return Colors.red;
  }