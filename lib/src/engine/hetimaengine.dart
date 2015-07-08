library hetimascript.engine;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async';

import '../lexer/hetimalexer.dart';
import '../lexer/hetimatoken.dart';
import './hetimaast.dart';

class HetimaObject {}

class HetimaFunction extends HetimaObject {
  void act(List<HetimaObject> args) {}
}

class NumberObject extends HetimaObject {
  num value = null;
  NumberObject(num value) {
    this.value = value;
  }
}

class StringObject extends HetimaObject {}

class TableObject extends HetimaObject {}

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

  Object setObject(String name, HetimaObject object) {
    map[name] = object;
  }

  Object getObject(String name, {bool isNewIfNeed: true}) {
    if (map.containsKey(name)) {
      return map[name];
    } else {
      // if(isNewIfNeed == true) {
      //   return newObject(name);
      // } else {
      throw {};
      // }
    }
  }
}

class HetimaInterpreter {
  ObjectManager manager = new ObjectManager();

  Future execute(HetimaAST t) {
    return new Future(() {
      switch (t.tokenId) {
        case HetimaToken.tkEqual:
          return execute(t.children[1]).then((a) {
            //
            manager.setObject(t.children[0].tokenName, a);
          });

        case HetimaToken.tkNumber:
          return new NumberObject(t.tokenValue[0]);
        case HetimaToken.tkAsterisk:
          return execute(t.children[0]).then((c) {
            return execute(t.children[1]).then((d) {
              return new NumberObject((c as NumberObject).value * (d as NumberObject).value);
            });
          });
        case HetimaToken.tkPulus:
          return execute(t.children[0]).then((c) {
            return execute(t.children[1]).then((d) {
              return new NumberObject((c as NumberObject).value + (d as NumberObject).value);
            });
          });
        case HetimaToken.tkMinus:
          return execute(t.children[0]).then((c) {
            return execute(t.children[1]).then((d) {
              return new NumberObject((c as NumberObject).value - (d as NumberObject).value);
            });
          });
        case HetimaToken.tkSlash:
          return execute(t.children[0]).then((c) {
            return execute(t.children[1]).then((d) {
              return new NumberObject((c as NumberObject).value / (d as NumberObject).value);
            });
          });
      }
    });
  }
}

