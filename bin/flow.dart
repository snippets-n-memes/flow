import 'dart:io';
import 'package:flow/repo.dart' as repo;
import 'package:flow/workflow.dart' as workflow;

const actionName = '';

void main(List<String> arguments) {
  exitCode = 0;

  // create config directory if not already done
  Directory("${Platform.environment["HOME"]}/.config/action")
      .createSync(recursive: true);

  // stripping first arg just to do it, no reason
  var newArgs = List<String>.from(arguments);
  if (arguments[0] == 'repo') {
    repo.add(newArgs..removeAt(0));
  } else {
    workflow.add(newArgs..removeAt(0));
  }
}
