library hetimascript.engine;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async';

import '../lexer/hetimalexer.dart';
import '../lexer/hetimatoken.dart';

class HetimaObject {}

class HetimaFunction extends HetimaObject {
  void act(List<HetimaObject> args) {}
}

class NumberObject extends HetimaObject {}
class StringObject extends HetimaObject {}

class PrintFunction extends HetimaObject {
  PrintFunction();
  void act(List<HetimaObject> args) {
    StringBuffer buffer = new StringBuffer();
    for (HetimaObject o in args) {
      buffer.write(o.toString());
    }
    print(buffer.toString());
  }
}

class ObjectManager {
  Map<String, HetimaObject> map = {};
  ObjectManager() {
    map["print"] = new PrintFunction();
  }
}

class HetimaInterpreter {
  Future play(HetimaAST t) {}
}

class HetimaAST {
  HetimaToken token;
  List<HetimaAST> children = [];

  HetimaAST(HetimaToken token, [List children]) {
    this.token = token;
    for (Object o in children) {
      if (o is HetimaAST) {
        addChild(o);
      } else if (o is HetimaToken) {
        addChildToken(o);
      }
    }
  }

  addChild(HetimaAST node) {
    children.add(node);
  }

  addChildToken(HetimaToken t) {
    children.add(new HetimaAST(t));
  }
}
