part of hetimascript;

List<String> luaXTokens = ["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"];

List<String> keywork2 = ["+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "..."];

List<String> keyword3 = ["\\a", "\\b", "\\f", "\\n", "\\r", "\\t", "\\v", "\\\\", "\\\"", "\\'"];

//
List<String> comment = ["--[", "]"];

///
///
///
///
///
///
class Token {
  static const none = 0;
  static const space = 1;
  static const comment = 2;
  static const minus = 3;
  static const crlf = 4;
  static const tkString = 5;
  static const tkOpeingBracket = 6;
  int kind = none;
  List<int> value = [];
  Token(int kind) {
    this.kind = kind;
  }

  Token.fromString(int kind, String text) {
    this.kind = kind;
    this.value = conv.UTF8.encode(text);
  }

  Token.fromList(int kind, List<int> text) {
    this.kind = kind;
    this.value = text;
  }
}

class Lexer {
  List<Token> tokenList = [];
  heti.HetimaBuilder _source = null;
  hregex.RegexEasyParser _parser = null;

  Lexer.create(heti.HetimaBuilder builder) {
    _source = builder;
    _parser = new hregex.RegexEasyParser(builder);
  }

  //
  async.Future<Token> lexer() {
    async.Completer<Token> completer = new async.Completer();
    _parser.push();
    _parser.readByte().then((int v) {
      switch (v) {
        case 0x20:
        case 0x0c:
        case 0x09:
        case 0x0b:
          {
            // " " "\f" "\t" "\v"
            _parser.pop();
            completer.complete(new Token(Token.space));
          }
          break;
        case 0x0a:
        case 0x0d:
          {
            // "\r" "\n"
            _parser.pop();
            completer.complete(new Token(Token.crlf));
          }
          break;
        case 0x2d:
          {
            // "-"
            _parser.back();
            _parser.pop();
            commentLong().then((String comment) {
              completer.complete(new Token.fromString(Token.comment, comment));
            }).catchError((e) {
              return commentShort();
            }).then((List<int> comment) {
              completer.complete(new Token.fromList(Token.comment, comment));
            }).catchError((e) {
              completer.complete(new Token(Token.minus));
            });
          }
          return;
        case 0x5b:
          {
            _parser.back();
            _parser.pop();
            // "["
            longStringA().then((List<int> v) {
              completer.complete(new Token.fromList(Token.tkString, v));
            }).catchError((e) {
              return longStringB().then((List<int> v) {
                completer.complete(new Token.fromList(Token.tkString, v));
              });
            }).catchError((e) {
              completer.complete(new Token(Token.tkOpeingBracket));
            });
          }
          break;
        default:
          completer.completeError([]);
      }
    });
    return completer.future;
  }

  static int _cv(String v) {
    return conv.UTF8.encode(v)[0];
  }

  async.Future<List<int>> newline() {
    return _parser.nextBytePatternByUnmatch(new heti.EasyParserIncludeMatcher([_cv('\n'), _cv('\r'), _cv('\0')]));
  }

  async.Future<List<int>> space() {
    return _parser.nextBytePatternByUnmatch(new heti.EasyParserIncludeMatcher([_cv(' '), _cv('\f'), _cv('\t'), _cv('\v')]));
  }

  async.Future<String> commentLong() {
    async.Completer<String> completer = new async.Completer();
    _parser.push();
    _parser.nextString("--[[").then((String v) {
      return _parser.nextStringByEnd("]]").then((String v) {
        return _parser.nextString("]]").then((String k) {
          _parser.pop();
          completer.complete(v);
        });
      });
    }).catchError((e) {
      _parser.back();
      _parser.pop();
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<int>> commentShort() {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    _parser.nextString("--").then((String v) {
      return _parser.nextBytePatternByUnmatch(new heti.EasyParserIncludeMatcher([_cv('\n'), _cv('\r')]), false).then((List<int> v) {
        completer.complete(v);
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<int>> longStringA() {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    hregex.RegexBuilder builder = new hregex.RegexBuilder();
    builder
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("[[")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UncharacterCommand(conv.UTF8.encode("]]"))))
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("]]")));
    _parser.readFromCommand(builder.done()).then((List<List<int>> v) {
      _parser.pop();
      completer.complete(v[0]);
    }).catchError((e) {
      _parser.back();
      _parser.pop();
      completer.completeError(e);
    });
    return completer.future;
  }
  async.Future<List<int>> longStringB() {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    hregex.RegexBuilder builder = new hregex.RegexBuilder();
    builder
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("[==[")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UncharacterCommand(conv.UTF8.encode("]==]"))))
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("]==]")));
    _parser.readFromCommand(builder.done()).then((List<List<int>> v) {
      _parser.pop();
      completer.complete(v[0]);
    }).catchError((e) {
      _parser.back();
      _parser.pop();
      completer.completeError(e);
    });
    return completer.future;
  }
}
