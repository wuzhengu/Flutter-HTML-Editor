import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/regex_provider.dart';

///
/// contains all information about an HTML tag, including:
///   - tagname
///   - if it is a start- or an end-tag
///   - properties (if any)
///   - style-properties (if any)
///   - the raw length of the tag for offset calculation
///
class Tag {
  /// tagname (without '<', '/' or '>')
  final String name;

  /// complete tag includin properties and brackets
  String rawTag;

  /// start, or end-tag
  final bool isStart;

  /// map of properties, mapping the html-key to it's value
  final Map<String, dynamic> properties;

  /// "style"-property with further split-up values
  Map<String, dynamic> styleProperties = {};

  /// the raw length of the tag in characters for offset calculation
  final int size;

  /// size of the corresponding end-tag. is equal to this.size if isStart is false
  int get endTagSize => name.length + 3;

  void putStyleProperty(String stylePropertyKey, String value) {
    // update the raw tag with as little changes as possible

    // create a style="" if not already present
    RegExp styleExpressionQuery = RegExp(r'style=".*"');
    if (!styleExpressionQuery.hasMatch(rawTag)) {
      rawTag = rawTag.substring(0, rawTag.length - 1) + " style=\"\">";
    }

    // if the style property is there, cut it
    var match = styleExpressionQuery.firstMatch(rawTag)!;
    if (styleProperties.containsKey(stylePropertyKey)) {
      var stylePropertyQuery =
          RegExp("$stylePropertyKey:.*[;\"]").firstMatch(rawTag)!;

      rawTag = rawTag.substring(0, stylePropertyQuery.start) +
          rawTag.substring(stylePropertyQuery.end - 1);
    }

    // account for style="
    var start = match.start + 7;
    rawTag = rawTag.substring(0, start) +
        "$stylePropertyKey:$value;" +
        rawTag.substring(start);

    styleProperties[stylePropertyKey] = value;
  }

  /// creates a new tag-representation. and decodes the "style" tag if present
  Tag(this.name, this.rawTag, this.properties, this.isStart, this.size) {
    if (properties.containsKey("style")) {
      String styleProp = this.properties["style"];
      List<String> properties = styleProp.split(";");

      for (String property in properties) {
        List<String> parts = property.split(":");
        String key = parts[0].trim();
        if (key.isEmpty) continue;

        String value = parts.length == 2 ? parts[1].trim() : "";
        styleProperties[key] = value;
      }
    }
  }

  @override
  String toString() {
    return "Tag($name, $properties)";
  }

  /// Decodes a random start- or end-tag encountered in HTML. [tag] is the full
  /// tag including brackets, properties, etc.
  ///
  /// Valid inputs:
  ///   - <p>
  ///   - <p style="font-weight:bold;">
  ///   - </p>
  factory Tag.decodeTag(String tag) {
    String tagClean =
        tag.substring(1, tag.length - 1).replaceAll("\s+", " ").trim();

    if (RegExProvider.startTagRegex.hasMatch(tag)) {
      List<String> tagParts = tagClean.split(" ");

      String tagName = tagParts[0];

      Map<String, dynamic> properties = {};

      for (int i = 1; i < tagParts.length; i++) {
        int splitPoint = tagParts[i].indexOf("=");

        String key = tagParts[i].substring(0, splitPoint);
        String value = tagParts[i].substring(splitPoint + 1);

        if (value.startsWith("\"")) value = value.substring(1);
        if (value.endsWith("\"")) value = value.substring(0, value.length - 1);

        properties[key] = value;
      }

      return Tag(tagName, tag, properties, true, tag.length);
    } else if (RegExProvider.endTagRegex.hasMatch(tag)) {
      return Tag(tag.substring(2, tag.length - 1), tag, {}, false, tag.length);
    }

    throw UndecodableTagException(tag);
  }
}
