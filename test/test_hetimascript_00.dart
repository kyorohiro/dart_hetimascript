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
     Lexer lexer = new Lexer.create(b);
     return lexer.commentShort().then((List<int> v) {
       expect(conv.UTF8.decode(v), "test");
       return lexer.newline();
     }).then((List<int> v){
       expect(conv.UTF8.decode(v), "\n");
       return lexer.commentShort();
     }).then((List<int> v){
       expect(conv.UTF8.decode(v), "test2");
       return lexer.newline();
     }).then((List<int> v){
       expect(conv.UTF8.decode(v), "\r\n");
       return lexer.space();
     }).then((List<int> v){ 
       expect(conv.UTF8.decode(v), " ");
     });
    });
    
    test('test2', () {
     String sc = """--[[test1]]--[[test2]]""";
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     Lexer lexer = new Lexer.create(b);
     return lexer.commentLong().then((String v) {
       expect(v, "test1");
       return lexer.commentLong();
     }).then((String v) {
       expect(v, "test2");
     });
    });
  });
}

void script01() {
  group('script02', () {
    test('test1', () {
     String sc = """--test\n--test2\r\n """;
     heti.ArrayBuilder b = new heti.ArrayBuilder.fromList(conv.UTF8.encode(sc), true);
     Lexer lexer = new Lexer.create(b);
     return lexer.lexer().then((Token t) {
       expect(t.kind, Token.comment);
       return lexer.lexer();
     }).then((Token t) {
       expect(t.kind, Token.crlf);  
       return lexer.lexer();
     }).then((Token t) {
       expect(t.kind, Token.comment);
       return lexer.lexer();
     }).then((Token t) {
       expect(t.kind, Token.crlf);  
       return lexer.lexer();
     });
    });
  });
}

//commentLong() 