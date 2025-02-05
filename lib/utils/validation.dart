// String emptyTextValidator(dynamic val) {
//   // if (val.isNotEmpty) {
//   //   return val;
//   // }
//   // return null;
//   return null;
// }

List<String> commaSeparatedStringToList(String? text) {
  final List<String> cleanWords = [];
  if (text != null && (text.isNotEmpty)) {
    final List<String> wordsList = text.split(",");
    for (String word in wordsList ?? []) {
      if (word.trim() != "") {
        cleanWords.add(word.trim());
      }
    }
  }
  return cleanWords;
}
