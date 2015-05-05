part of hetimascript;

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
}

