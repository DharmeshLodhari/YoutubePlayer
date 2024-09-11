import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:git_hooks/git_hooks.dart';

void main(List<String> arguments) {
  // ignore: omit_local_variable_types
  final Map<Git, UserBackFun> params = {
    Git.commitMsg: commitMsg,
    Git.preCommit: preCommit
  };
  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  final commitMsg = Utils.getCommitEditMsg();
  if (commitMsg.startsWith('fix:')) {
    return true; // you can return true let commit go
  } else {
    debugPrint('you should add `fix` in the commit message');
    return false;
  }
}

Future<bool> preCommit() async {
  try {
    final ProcessResult result = await Process.run('dartanalyzer', ['bin']);
    // debugPrint("Result : ${result.stdout}");
    if (result.exitCode != 0) return false;
  } catch (e) {
    return false;
  }
  return true;
}
