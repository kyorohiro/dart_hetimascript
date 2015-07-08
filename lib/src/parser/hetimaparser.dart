library hetimascript.parser;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async';
import '../lexer/hetimalexer.dart';
import '../lexer/hetimatoken.dart';
import '../engine/hetimaast.dart';

class HetimaParser {
  HetimaLexer _lexer = null;

  List<HetimaToken> _lookahead = [];
  List<int> _stack = [];
  int _index = 0;

  push() {
    _stack.add(_index);
  }

  back() {
    _index = _stack.last;
  }

  pop() {
    _stack.removeLast();
    if (_stack.length == 0) {
      _lookahead.clear();
    }
  }

  Future<HetimaToken> nextToken() {
    if(_index < _lookahead.length) {
      return new Future((){
        return _lookahead[_index];
      });
    } else {
      return _lexer.next().then((HetimaToken t) {
        if(_stack.length != 0) {
          _lookahead.add(t);
        }
        return t;
      });
    }
  }

  HetimaParser.create(HetimaLexer lexer) {
    this._lexer = lexer;
  }

  Future<HetimaAST> execute(HetimaLexer lexer) {
    Completer<HetimaAST> c = new Completer();
    grammerStat().then((_) {
      c.complete();
    }).catchError((e){c.completeError(e);});
    return c.future;
  }

  // exp ::=  nil | false | true | Number | String | `...´ | function |
  // prefixexp | tableconstructor | exp binop exp | unop exp
  Future grammerExp() {
    return _lexer.next().then((HetimaToken t) {
      push();
    });
  }

  //binop ::= `+´ | `-´ | `*´ | `/´ | `^´ | `%´ | `..´ |
  //  `<´ | `<=´ | `>´ | `>=´ | `==´ | `~=´ |
  //  and | or
  Future grammerBinop() {
    return _lexer.next().then((HetimaToken t) {
      push();
    });
  }

  //  stat ::=  varlist `=´ explist |
  // functioncall |
  // do block end |
  // while exp do block end |
  // repeat block until exp |
  // if exp then block {elseif exp then block} [else block] end |
  // for Name `=´ exp `,´ exp [`,´ exp] do block end |
  // for namelist in explist do block end |
  // function funcname funcbody |
  // local function Name funcbody |
  // local namelist [`=´ explist]
  Future grammerStat() {
    return grammerVar().then((a) {
      
    });
    return _lexer.next().then((HetimaToken t) {
      if (t.kind != HetimaToken.tkNumber) {
        throw {};
      }
    });
  }

  //varlist ::= var {`,´ var}
  Future grammerVarlist() {
    return _lexer.next().then((HetimaToken t) {
      if (t.kind != HetimaToken.tkNumber) {
        throw {};
      }
    });
  }

  //var ::=  Name | prefixexp `[´ exp `]´ | prefixexp `.´ Name
  Future grammerVar() {
    return _lexer.next().then((HetimaToken t) {
      if (t.kind != HetimaToken.tkNumber) {
        throw {};
      }
    });
  }

  Future grammerNumber() {
    return _lexer.next().then((HetimaToken t) {
      if (t.kind != HetimaToken.tkNumber) {
        throw {};
      }
    });
  }
}
