library test_lexer;

import 'package:hetimascript/hetimascript.dart';
import 'package:unittest/unittest.dart';
import 'package:hetimacore/hetimacore.dart' as heti;
import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('script01', () {
    test('*', () {
      HetimaInterpreter interpreter = new HetimaInterpreter();
      HetimaAST root = new HetimaAST(new HetimaToken(HetimaToken.tkEqual));
      root.addChildToken(new HetimaToken.fromString(HetimaToken.tkName, "a"));
      root.addChild(new HetimaAST(new HetimaToken(HetimaToken.tkAsterisk),
          [new HetimaToken.fromNumber(HetimaToken.tkNumber, 2),
           new HetimaToken.fromNumber(HetimaToken.tkNumber, 3)]
      ));
      return interpreter.execute(root).then((_){
        HetimaObject object = interpreter.manager.getObject("a");
        expect(object is NumberObject, true);
        expect((object as NumberObject).value, 6);
      });
    });

    test('+', () {
      HetimaInterpreter interpreter = new HetimaInterpreter();
      HetimaAST root = new HetimaAST(new HetimaToken(HetimaToken.tkEqual));
      root.addChildToken(new HetimaToken.fromString(HetimaToken.tkName, "a"));
      root.addChild(new HetimaAST(new HetimaToken(HetimaToken.tkPulus),
          [new HetimaToken.fromNumber(HetimaToken.tkNumber, 2),
           new HetimaToken.fromNumber(HetimaToken.tkNumber, 3)]
      ));
      return interpreter.execute(root).then((_){
        HetimaObject object = interpreter.manager.getObject("a");
        expect(object is NumberObject, true);
        expect((object as NumberObject).value, 5);
      });
    });
    test('-', () {
      HetimaInterpreter interpreter = new HetimaInterpreter();
      HetimaAST root = new HetimaAST(new HetimaToken(HetimaToken.tkEqual));
      root.addChildToken(new HetimaToken.fromString(HetimaToken.tkName, "a"));
      root.addChild(new HetimaAST(new HetimaToken(HetimaToken.tkMinus),
          [new HetimaToken.fromNumber(HetimaToken.tkNumber, 2),
           new HetimaToken.fromNumber(HetimaToken.tkNumber, 3)]
      ));
      return interpreter.execute(root).then((_){
        HetimaObject object = interpreter.manager.getObject("a");
        expect(object is NumberObject, true);
        expect((object as NumberObject).value, -1);
      });
    });
    
    test('/', () {
      HetimaInterpreter interpreter = new HetimaInterpreter();
      HetimaAST root = new HetimaAST(new HetimaToken(HetimaToken.tkEqual));
      root.addChildToken(new HetimaToken.fromString(HetimaToken.tkName, "a"));
      root.addChild(new HetimaAST(new HetimaToken(HetimaToken.tkSlash),
          [new HetimaToken.fromNumber(HetimaToken.tkNumber, 6),
           new HetimaToken.fromNumber(HetimaToken.tkNumber, 3)]
      ));
      return interpreter.execute(root).then((_){
        HetimaObject object = interpreter.manager.getObject("a");
        expect(object is NumberObject, true);
        expect((object as NumberObject).value, 2);
      });
    });
  });
}
