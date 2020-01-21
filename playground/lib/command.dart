import 'dart:io';
import 'dart:convert';
import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';

class CommandRun {

  String _path;

  List<Command> preCommands = [];

  List<List<Command>> requestAnimationFrameCommands = [];

  CommandRun(this._path);

  void init() {
    List<String> content = File(_path).readAsLinesSync();

    bool isPre = true;

    List<Command> commands;
    for (String string in content) {
      int index = string.indexOf(" ");
      String method = string.substring(0, index);
      if (method == 'requestAnimationFrame') {
        isPre = false;
        if (commands != null) {
          requestAnimationFrameCommands.add(commands);
        }
        commands = [];
        continue;
      }
      dynamic params = jsonDecode(string.substring(index + 1));
      if (isPre) {
        preCommands.add(Command(method, params));
      } else {
        commands.add(Command(method, params));
      }
    }

    if (commands.isNotEmpty) {
      requestAnimationFrameCommands.add(commands);
    }
  }

  void run() {
    init();
    for (Command command in preCommands) {
      command.run();
    }

    _runRequestAnimationFrameCommand(0);
  }

  void _runRequestAnimationFrameCommand(int current) {
    if (current < requestAnimationFrameCommands.length) {
      ElementsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        for (Command command in requestAnimationFrameCommands[current]) {
          command.run();
        }
        _runRequestAnimationFrameCommand(++current);
      });
      ElementManager().getRootRenderObject().markNeedsPaint();
      // Call for paint to trigger painting frame manually.
    }
  }
}

class Command {
  String method;
  List<dynamic> params;

  Command(this.method, this.params);

  void run() {
    switch (method) {
      case 'setStyle':
        setStyle(params[0], params[1], params[2]);
        break;
      case 'createElement':
        Map map = params[0];
        createElement(map['type'], map['id'], map['props'].toString(), map['events'].toString());
        break;
      case 'insertAdjacentNode':
        insertAdjacentNode(params[0], params[1], params[2]);
        break;
    }
  }
}
