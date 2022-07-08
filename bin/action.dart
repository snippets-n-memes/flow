import 'package:action/repo.dart' as repo;
import 'package:action/workflow.dart' as workflow;
import 'dart:io';

const actionName = '';

void main(List<String> arguments) {
  exitCode = 0;
  var newArgs = List<String>.from(arguments);
  if (arguments[0] == 'repo') {
    repo.add(newArgs..removeAt(0));
  } else {
    workflow.add(newArgs..removeAt(0));
  }
}
