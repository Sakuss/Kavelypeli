import 'dart:math';

class Util {
  String generateStepsCount(){
    double minVal = 500;
    double maxVal = 1999;

    Random rand = Random();

    return (rand.nextDouble() * (maxVal - minVal) + minVal).round().toString();
  }
}