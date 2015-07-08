library hetimascript.ast;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async';

import '../lexer/hetimalexer.dart';
import '../lexer/hetimatoken.dart';



class HetimaAST {
  HetimaToken token;
  List<HetimaAST> children = [];

  int get tokenId => token.kind;
  List<int> get tokenValue => token.value;
  String get tokenName => conv.UTF8.decode(token.value);

  HetimaAST(HetimaToken token, [List children = null]) {
    this.token = token;
    if (children != null) {
      for (Object o in children) {
        if (o is HetimaAST) {
          addChild(o);
        } else if (o is HetimaToken) {
          addChildToken(o);
        }
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
