double landWeightKg({required double enteredWeight, required String unit}) {
  return unit == 'TON' ? enteredWeight * 1000 : enteredWeight;
}
