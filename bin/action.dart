import 'dart:io';
import 'package:action/repo.dart' as repo;
import 'package:action/workflow.dart' as workflow;

const actionName = '';

void main(List<String> arguments) {
  exitCode = 0;

  Directory("${Platform.environment["HOME"]}/.config/action")
      .createSync(recursive: true);

  var newArgs = List<String>.from(arguments);
  if (arguments[0] == 'repo') {
    repo.add(newArgs..removeAt(0));
  } else {
    workflow.add(newArgs..removeAt(0));
  }
}
