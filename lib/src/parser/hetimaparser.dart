library hetimascript.parser;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async' as async;
import '../lexer/hetimalexer.dart';
import '../lexer/hetimatoken.dart';


class HetimaParser {
  HetimaLexer _lexer = null;

  List<HetimaToken> _lookahead = [];
  List<int> _stack = [];
  int _index = 0;

  push() {
   _stack.add(_lookahead.length-1); 
  }

  back() {
    _index = _stack.last;
  }

  pop() {
    _stack.removeLast();
    if(_stack.length == 0) {
      _lookahead.clear();
    }
  }

  HetimaParser.create(HetimaLexer lexer) {
    this._lexer = lexer;
  }

  async.Future<int> execute(HetimaLexer lexer) {
    async.Completer<int> c = new async.Completer();
    grammerStat(c);
    return c.future;
  }
  
  async.Future grammerVar() {
    return null;
  }

  void grammerStat(async.Completer<int> c) {
    grammerVar().then((e){
      return _lexer.next();
    }).then((HetimaToken v){
      if(v == HetimaToken.tkEqual) {
        return _lexer.next();
      } else {
        throw new Exception("");
      }
    }).then((HetimaToken v){
      
    });
     
    _lexer.next().then((HetimaToken t) {
      switch(t.kind) {
        case HetimaToken.tkComment:
        c.complete(0);
        break;
        case HetimaToken.tkName:
      }
    });
  }
}

