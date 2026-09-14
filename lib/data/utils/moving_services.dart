List<String> combinedMovingServices({
  required bool packingRequired,
  required bool unpackingRequired,
  required bool furnitureDisassembly,
  required bool storageRequired,
  required bool insuranceRequested,
  required Iterable<String> additionalServices,
}) {
  return <String>[
    if (packingRequired) 'Professional Packing',
    if (unpackingRequired) 'Unpacking',
    if (furnitureDisassembly) 'Furniture Disassembly',
    if (storageRequired) 'Temporary Storage',
    if (insuranceRequested) 'Moving Insurance',
    ...additionalServices,
  ];
}
