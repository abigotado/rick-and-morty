extension JsonReader on Map<String, dynamic> {
  T read<T>(String key) {
    if (!containsKey(key)) throw FormatException('Missing "$key"');
    final value = this[key];
    if (value is T) return value;
    throw FormatException('Expected $T at "$key", got ${value.runtimeType}');
  }

  List<Map<String, dynamic>> readObjects(String key) {
    return [
      for (final item in read<List<dynamic>>(key))
        if (item is Map<String, dynamic>)
          item
        else
          throw FormatException('Expected objects in "$key", got ${item.runtimeType}'),
    ];
  }
}
