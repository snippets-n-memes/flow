import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

final baseUrl = 'https://api.github.com/repos/';
final manifestPath = '/contents/manifest.yml';

add(arguments) async {
  var repo = arguments[1];
  var url = Uri.parse('$baseUrl$repo$manifestPath');
  Map<String, String> headers = {
    "Content-type": "application/vnd.github.VERSION.raw",
    "Accept": "application/vnd.github+json"
  };

  var response = await http.get(url, headers: headers);

  var yaml = utf8.decode(base64
      .decode(json.decode(response.body)["content"].replaceAll("\n", "")));

  var yamlmap = loadYaml(yaml);

  var jason = json.encode(yamlmap);
  final object = json.decode(jason);
  final prettyString = JsonEncoder.withIndent('  ').convert(object);

  // Write
  final filename = '.actionsconfig';
  await File(filename).writeAsString(prettyString);

  // Read and modify
  File(filename).readAsString().then((String contents) {
    // print(contents);
    Map<dynamic, dynamic> pam = json.decode(contents);
    Map<dynamic, dynamic> map = {};

    final base = <String, dynamic>{"installed": []};

    map.addEntries(base.entries);
    map["installed"].add({
      "${arguments[1]}": {"actions": "${pam["repo"]["actions"]}"}
    });

    print(json.encode(map));
  });
}
