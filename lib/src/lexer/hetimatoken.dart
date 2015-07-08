library hetimascript.token;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async' as async;

List<String> luaXTokens = ["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"];

class HetimaToken {
  static const tkNone = 0;
  static const tkSpace = 1;
  static const tkComment = 2;
  static const tkMinus = 3;
  static const tkCrlf = 4;
  static const tkString = 5;
  static const tkOpeingBracket = 6;
  static const tkEqual = 7;
  static const tkEqualEqual = 8;
  static const tkGraterThanSign = 9; //>
  static const tkGraterThanEqualSign = 10; // >=
  static const tkRightShift = 11; //>>
  static const tkLessThanSign = 12; //<
  static const tkLessThanEqualSign = 13; // <=
  static const tkLeftShift = 12; //<<
  static const tkSlash = 13; // /
  static const tkNotEqual = 14; // ~=
  static const tkTilde = 15; // ~
  static const tkColon = 16; // :
  static const tkDoubleColon = 17; // ::
  static const tkDot = 18; // .
  static const tkConcat = 19; // ..
  static const tkDots = 20; // ...
  static const tkNumber = 21; // 
  static const tkPulus = 22; //+
  static const tkAsterisk = 23; // *
  static const tkPercent = 24;// %
  static const tkCaret = 25; // ^
  static const tkHashMark = 26; //#
  static const tkLeftParen = 27; // (
  static const tkRightParen = 28; // )
  static const tkLeftBracket = 29; //[
  static const tkRightBracket = 30; //]
  static const tkLeftBrace = 31;//{
  static const tkRightBrace = 32;//}
  static const tkSemicolon = 33;// ;
  static const tkComma= 34;//
  static const tkName= 35;//
  static const tkEOF= -1;//
  int kind = tkNone;
  List<int> value = [];
  HetimaToken(int kind) {
    this.kind = kind;
  }

  HetimaToken.fromString(int kind, String text) {
    this.kind = kind;
    this.value = conv.UTF8.encode(text);
  }

  HetimaToken.fromNumber(int kind, num v) {
    this.kind = kind;
    this.value = [v];
  }

  HetimaToken.fromList(int kind, List<int> text) {
    this.kind = kind;
    this.value = text;
  }
  
  // " " "\f" "\t" "\v"
  static final List<int> spaceSign = [0x20, 0x0c, 0x09, 0x0b];
  // "\r" "\n"
  static final List<int> crlfSign = [0x0a, 0x0d];
  static final List<int> numberBeginSign = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39];

  static final List<int> nameBeginSign = [
    0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,
    0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
    0x70,0x71,0x72,0x72,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,
    0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,
    0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
    0x50,0x51,0x52,0x52,0x54,0x55,0x56,0x57,0x58,0x59,0x5a];

  static final List<int> stringBeginSign = [0x22,0x27];
  static final Map<int, int> singleConvertMap = {
    0x2b:HetimaToken.tkPulus,
    0x2a:HetimaToken.tkAsterisk,
    0x2f:HetimaToken.tkSlash,
    0x25:HetimaToken.tkPercent,
    0x5e:HetimaToken.tkCaret,
    0x23:HetimaToken.tkHashMark,
    0x28:HetimaToken.tkLeftParen,
    0x29:HetimaToken.tkRightParen,
    0x7b:HetimaToken.tkLeftBrace,
    0x7d:HetimaToken.tkRightBrace,
   // 0x5b:HetimaToken.tkLeftBracket,
    0x5d:HetimaToken.tkRightBracket,
    0x3b:HetimaToken.tkSemicolon,
    0x2c:HetimaToken.tkComma,
    0xff:HetimaToken.tkEOF,
  };
}


