library test_lexer;

import 'package:hetimascript/hetimascript.dart';
import 'package:unittest/unittest.dart';
import 'package:hetimacore/hetimacore.dart' as heti;
import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('script01', () {
    test('test1', () {
      HetimaInterpreter interpreter = new HetimaInterpreter();
      HetimaAST root = new HetimaAST(new HetimaToken(HetimaToken.tkEqual));
      root.addChildToken(new HetimaToken.fromString(HetimaToken.tkName, "a"));
      root.addChild(new HetimaAST(new HetimaToken(HetimaToken.tkAsterisk),
          [new HetimaToken.fromNumber(HetimaToken.tkNumber, 2),
           new HetimaToken.fromNumber(HetimaToken.tkNumber, 3)]
      ));
      interpreter.play(root);
    });
  });
}
