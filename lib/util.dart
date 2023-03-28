import 'dart:math';

class Util {
  String generateStepsCount(){
    double minVal = 1;
    double maxVal = 9999;

    Random rand = Random();

    return (rand.nextDouble() * (maxVal - minVal) + minVal).round().toString();
  }
}