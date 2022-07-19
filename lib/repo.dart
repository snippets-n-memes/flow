import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

final baseUrl = 'https://api.github.com/repos/';
final manifestPath = '/contents/manifest.yml';
final base = <String, dynamic>{"installed": {}};
final config = "${Platform.environment["HOME"]}/.config/action/config.json";

fetchActions(arguments) async {
  Map<String, String> headers = {
    "Content-type": "application/vnd.github.VERSION.raw",
    "Accept": "application/vnd.github+json"
  };

  var repo = arguments[1];
  var url = Uri.parse('$baseUrl$repo$manifestPath');

  var response = await http.get(url, headers: headers);

  // make sure we've got a repo with a manifest file
  String yaml = "";
  try {
    yaml = utf8.decode(base64.decode(
    json.decode(response.body)["content"].replaceAll("\n", "")));
  }
  on NoSuchMethodError {
    // no content to replaceAll() on if no manifest
    print("${repo} is not a useful repo");
    exit(1);
  }
  catch(e) {
    print("$e is a new one");
    exit(2);
  }

  return yaml;
}

write(arguments, config, map) async{
  var repo = arguments[1];

  final added = "${repo} added.\n"
    "Use `action add ${repo} <ACTION_SLUG>` "
    "to add an Action to your repo";

  final pam = json.decode(
    json.encode(loadYaml(await fetchActions(arguments))));   

  map["installed"][repo] = {"actions": pam["repo"]["actions"]};
  
  // write the file in pretty format
  await File(config)
  .writeAsString(JsonEncoder.withIndent('  ')
  .convert(map));

  print(added);
}

// add a repo to the config file
add(arguments) async {

  var repo = arguments[1];
  // yaml -> yamlMap -> json -> Map <String, dynamic>

  if (! await File(config).exists()) {

    // create the config file and add first repo
    Map<dynamic, dynamic> map = {};
    map.addEntries(base.entries);
    write(arguments, config, map);


  } else {
 
    Map<dynamic, dynamic> map = json.decode(
      await File(config).readAsString());

    // check for existing record of repo to be added before adding
    if (map["installed"].containsKey(repo)) {
      print("${repo} already installed");
      exit(0);
    }

    write(arguments, config, map);
  }
}
