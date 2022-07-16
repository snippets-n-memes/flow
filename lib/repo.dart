import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

final baseUrl = 'https://api.github.com/repos/';
final manifestPath = '/contents/manifest.yml';
final base = <String, dynamic>{"installed": []};
final config = "${Platform.environment["HOME"]}/.config/action/config.json";

// add a repo to the config file
add(arguments) async {

  final added = "${arguments[1]} added.\n"
    "Use `action add ${arguments[1]} <ACTION_SLUG>` "
    "to add an Action to your repo";

  var repo = arguments[1];
  var url = Uri.parse('$baseUrl$repo$manifestPath');

  Map<String, String> headers = {
    "Content-type": "application/vnd.github.VERSION.raw",
    "Accept": "application/vnd.github+json"
  };

  var response = await http.get(url, headers: headers);

  // make sure we've got a repo with a manifest file
  String yaml = "";
  try {
    yaml = utf8.decode(base64.decode(
    json.decode(response.body)["content"].replaceAll("\n", "")));
  }
  on NoSuchMethodError {
    // no content to replaceAll() on if no manifest
    print("${arguments[1]} is not a useful repo");
    exit(1);
  }
  catch(e) {
    print("$e is a new one");
    exit(2);
  }

  // yaml -> yamlMap -> json -> Map <String, dynamic>
  final pam = json.decode(
    json.encode(loadYaml(yaml)));

  var configExists = await File(config).exists();

  if (configExists == false) {

    // create the config file and add first repo
    Map<dynamic, dynamic> map = {};
    map.addEntries(base.entries);
    map["installed"].add({
      "${arguments[1]}": {"actions": "${pam["repo"]["actions"]}"}
    });
    
    // write the file in pretty format
    await File(config)
    .writeAsString(JsonEncoder.withIndent('  ')
    .convert(map));

    print(added);

  } else {
 
    Map<dynamic, dynamic> map = json.decode(
      await File(config).readAsString());

    // check for existing record of repo to be added before adding
    for (var i = 0; i < map["installed"].length; i++) {
      if (map["installed"][i].containsKey(arguments[1])) {
        print("${arguments[1]} already installed");
        exit(0);
      }
    }
    map["installed"].add({
      "${arguments[1]}": {"actions": "${pam["repo"]["actions"]}"}
    });
    
    // write the file in pretty format
    await File(config)
    .writeAsString(JsonEncoder.withIndent('  ')
    .convert(map));

    print(added);
  }
}
