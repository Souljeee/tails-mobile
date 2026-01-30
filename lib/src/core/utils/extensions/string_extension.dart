/// Common extensions for [String]
extension StringExtension on String {
  /// Returns a new string with the first [length] characters of this string.
  String limit(int length) => length < this.length ? substring(0, length) : this;

  String toFirstLetterUpperCase() {
    return length == 0 ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

