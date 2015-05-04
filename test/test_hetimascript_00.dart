library dart_hetimascript_test;

import 'package:hetimascript/hetimascript.dart';
import 'package:unittest/unittest.dart';
import 'package:hetimacore/hetimacore.dart' as heti;
import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('script01', () {
    test('test1', () {
     String sc = """--test\n--test2\r\n """;
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.commentShort().then((List<int> v) {
       expect(conv.UTF8.decode(v), "test");
     });
    });

    test('test2', () {
     String sc = """--[[test1]]--[[test2]]""";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.commentLong().then((String v) {
       expect(v, "test1");
       return lexer.commentLong();
     }).then((String v) {
       expect(v, "test2");
     });
    });

    test('test3', () {
     String sc = """[[test1]][[test2]]""";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.longStringA().then((List<int> v) {
       expect(conv.UTF8.decode(v), "test1");
       return lexer.longStringA();
     }).then((List<int> v) {
       expect(conv.UTF8.decode(v), "test2");
     });
    });
    
    test('test4', () {
     String sc = "\"aa\"\"bb\"";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.normalString().then((List<int> v){
       expect(conv.UTF8.decode(v), "aa");
       return lexer.normalString();      
     }).then((List<int> v) {
       expect(conv.UTF8.decode(v), "bb");       
     });
    });
    
    test('test5', () {
     String sc = "\"aabb";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.normalString().then((List<int> v){
       expect(true,false);
     }).catchError((e){
       expect(true,true);
     });
    });

    test('test6 hexnumber 1', () {
     String sc = "0xff";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.hexNumber().then((num v){
       expect(v,255);
     }).catchError((e){
       expect(true,false);
     });
    });
    test('test6 number .5', () {
     String sc = ".5";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.normalNumber().then((num v){
       expect(v,0.5);
     }).catchError((e){
       expect(true,false);
     });
    });
    test('test6 hexnumber 2', () {
     String sc = "0x.5";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.hexNumber().then((num v){
       expect(v,0.5);
     }).catchError((e){
       expect(true,false);
     });
    });
  });
}

void script01() {
  group('script02', () {
    test('test1', () {
     String sc = """--test\n--test2\r\n """;
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.lexer().then((HetimaToken t) {
       expect(t.kind, HetimaToken.tkComment);
       return lexer.lexer();
     }).then((HetimaToken t) {
       expect(t.kind, HetimaToken.tkCrlf);  
       return lexer.lexer();
     }).then((HetimaToken t) {
       expect(t.kind, HetimaToken.tkComment);
       return lexer.lexer();
     }).then((HetimaToken t) {
       expect(t.kind, HetimaToken.tkCrlf);  
       return lexer.lexer();
     });
    });
    
    test('script03', () {
     String sc = """[[test1]][==[test2]==][""";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.lexer().then((HetimaToken v) {
       expect(conv.UTF8.decode(v.value), "test1");
       return lexer.lexer();
     }).then((HetimaToken v) {
       expect(conv.UTF8.decode(v.value), "test2");
       return lexer.lexer();
     }).then((HetimaToken v) {
       expect(v.kind, HetimaToken.tkOpeingBracket);
     });
    });

    test('script04', () {
     String sc = "\"abc\"\'xyz\'";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     HetimaLexer lexer = new HetimaLexer.create(b);
     return lexer.lexer().then((HetimaToken v) {
       expect(conv.UTF8.decode(v.value), "abc");
       return lexer.lexer();
     }).then((HetimaToken v) {
       expect(conv.UTF8.decode(v.value), "xyz");
     });
    });

    

  });
}

//commentLong() 