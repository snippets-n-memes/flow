import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

final baseUrl = 'https://api.github.com/repos/';
final manifestPath = '/contents/manifest.yml';
final base = <String, dynamic>{"installed": []};
final config = "${Platform.environment["HOME"]}/.config/action/config.json";

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
  final pam = json.decode(json.encode(loadYaml(yaml)));

  var configExists = File(config).existsSync();
  if (configExists == false) {
    Map<dynamic, dynamic> map = {};
    map.addEntries(base.entries);
    map["installed"].add({
      "${arguments[1]}": {"actions": "${pam["repo"]["actions"]}"}
    });
    await File(config).writeAsString(JsonEncoder.withIndent('  ').convert(map));
  } else {
    String contents = File(config).readAsStringSync();
    Map<dynamic, dynamic> map = json.decode(contents);
    if (!map["installed"].toString().contains(arguments[1])) {
      map["installed"].add({
        "${arguments[1]}": {"actions": "${pam["repo"]["actions"]}"}
      });
      await File(config)
          .writeAsString(JsonEncoder.withIndent('  ').convert(map));
    } else {
      print("${arguments[1]} already installed");
    }
  }
}
