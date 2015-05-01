part of hetimascript;

List<String> luaXTokens = [
  "and",
  "break",
  "do",
  "else",
  "elseif",
  "end",
  "false",
  "for",
  "function",
  "if",
  "in",
  "local",
  "nil",
  "not",
  "or",
  "repeat",
  "return",
  "then",
  "true",
  "until",
  "while"
];

List<String> keywork2 = [
  "+",
  "-",
  "*",
  "/",
  "%",
  "^",
  "#",
  "==",
  "~=",
  "<=",
  ">=",
  "<",
  ">",
  "=",
  "(",
  ")",
  "{",
  "}",
  "[",
  "]",
  ";",
  ":",
  ",",
  ".",
  "..",
  "..."
];

List<String> keyword3 = [
  "\\a",
  "\\b",
  "\\f",
  "\\n",
  "\\r",
  "\\t",
  "\\v",
  "\\\\",
  "\\\"",
  "\\'"
];

//
List<String> comment = ["--[", "]"];

class Lexer {
  List<Token> tokenList = [];
  heti.HetimaBuilder _source = null;
  heti.EasyParser _parser = null;

  Lexer.create(heti.HetimaBuilder builder) {
    _source = builder;
    _parser = new heti.EasyParser(builder);
  }

  Token peek() {
    return null;
  }

  static int _cv(String v) {
    return conv.UTF8.encode(v)[0];
  }

  async.Future<List<int>> newline() {
    return _parser.nextBytePatternByUnmatch(
        new heti.EasyParserIncludeMatcher([_cv('\n'), _cv('\r'), _cv('\0')]));
  }

  async.Future<List<int>> space() {
    return _parser.nextBytePatternByUnmatch(new heti.EasyParserIncludeMatcher(
        [_cv(' '), _cv('\f'), _cv('\t'), _cv('\v')]));
  }

  async.Future<String> commentLong() {
    async.Completer<String> completer = new async.Completer();
    _parser.push();
    _parser.nextString("--[[").then((String v) {
      return _parser.nextStringByEnd("]]").then((String v) {
        return _parser.nextString("]]").then((String k){
          completer.complete(v);          
        });
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<int>> commentShort() {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    _parser.nextString("--").then((String v) {
      return _parser
          .nextBytePatternByUnmatch(
              new heti.EasyParserIncludeMatcher([_cv('\n'), _cv('\r')]), false)
          .then((List<int> v) {
        completer.complete(v);
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}

class Token {}
