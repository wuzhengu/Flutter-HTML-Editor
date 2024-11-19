import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/v3/parser.dart';

void main() {
  var parser = LightHtmlParserV3();

  test('parser: parse link with funny characters', () {
    var tree = parser.parse(
        "<a href=\"https://docs.google.com/document/d/1hyG6jfN70hgvJf29tgkf9ES_A5z4S_gpTrVm4tBl1-c/edit?tab=t.0#heading=h.zfxyzw41gz69\">lol</a>");

    expect(tree.children.length, equals(1));

    var child = tree.children.first;

    expect(child.tag, isNotNull);
    expect(child.tag!.name, equals("a"));

    var properties = child.tag!.properties;

    expect(properties.keys.contains("href"), equals(true));
    expect(properties["href"],
        "https://docs.google.com/document/d/1hyG6jfN70hgvJf29tgkf9ES_A5z4S_gpTrVm4tBl1-c/edit?tab=t.0#heading=h.zfxyzw41gz69");
  });

  test('parser: parse empty string', () {
    var tree = parser.parse("");

    expect(tree.height, equals(0));
    expect(tree.isRoot, equals(true));
    expect(tree.isPlaintext, equals(false));
    expect(tree.isTag, equals(true));
  });

  test('parser: parse empty string', () {
    var tree = parser.parse("");

    expect(tree.height, equals(0));
    expect(tree.isRoot, equals(true));
    expect(tree.isPlaintext, equals(false));
    expect(tree.isTag, equals(true));
  });

  test('parser: parse only plaintext', () {
    var tree = parser.parse("some text");

    expect(tree.height, equals(1));
    expect(tree.hasChildren, equals(true));
    expect(tree.children.length, equals(1));

    var child = tree.children.first;

    expect(child.isPlaintext, equals(true));
    expect(child.hasChildren, equals(false));
    expect(child.content, equals("some text"));
  });

  test('parser: plaintext with one node', () {
    var tree = parser.parse("some input <b>tag</b>");

    expect(tree.height, equals(2));
    expect(tree.scopeStart, equals(0));
    expect(tree.scopeEnd, equals(21));
  });

  test('parser: more complex tree', () {
    var tree = parser.parse("some input <b>tag 1</b><b>tag 2<b>tag 3</b></b>");

    expect(tree.height, equals(3));
    expect(tree.scopeEnd, equals(47));
  });
}
