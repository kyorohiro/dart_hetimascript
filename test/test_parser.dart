library test_parser;

import 'package:hetimascript/hetimascript.dart';
import 'package:unittest/unittest.dart';
import 'package:hetimacore/hetimacore.dart' as heti;
import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

String sample1 = """
--[[Hello Lua]]

""";

void main() {
  group('parser', () {
    test('a=1', () {
      String sc = "a=1";
      heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
      HetimaLexer lexer = new HetimaLexer.create(b);
      HetimaParser parser = new HetimaParser.create(lexer);
      return parser.execute(lexer).then((HetimaAST v){
        ;
      });
    });
  });
}
