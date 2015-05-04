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
  static const tkGraterThanSign = 9;//>
  static const tkGraterThanEqualSign = 10;// >=
  static const tkRightShift = 11;//>>
  static const tkLessThanSign = 12;//<
  static const tkLessThanEqualSign = 13;// <= 
  static const tkLeftShift = 12;//<<
  static const tkSlash = 13;
  static const tkNotEqual = 14;// ~=
  static const tkTilde = 15;// ~
  static const tkColon = 16; // :
  static const tkDoubleColon = 17; // ::
  static const tkDot = 18;
  static const tkConcat = 19; // ..
  static const tkDots = 20; // ...

  int kind = tkNone;
  List<int> value = [];
  HetimaToken(int kind) {
    this.kind = kind;
  }

  HetimaToken.fromString(int kind, String text) {
    this.kind = kind;
    this.value = conv.UTF8.encode(text);
  }

  HetimaToken.fromList(int kind, List<int> text) {
    this.kind = kind;
    this.value = text;
  }
}

class HetimaLexer {
  List<HetimaToken> tokenList = [];
  hregex.RegexEasyParser _parser = null;

  HetimaLexer.create(heti.HetimaBuilder builder) {
    _parser = new hregex.RegexEasyParser(builder);
  }

  //
  async.Future<HetimaToken> lexer() {
    async.Completer<HetimaToken> completer = new async.Completer();
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
            completer.complete(new HetimaToken(HetimaToken.tkSpace));
          }
          break;
        case 0x0a:
        case 0x0d:
          {
            // "\r" "\n"
            _parser.pop();
            completer.complete(new HetimaToken(HetimaToken.tkCrlf));
          }
          break;
        case 0x2d:
          {
            // "-"
            _parser.back();
            _parser.pop();
            commentLong().then((String comment) {
              completer.complete(new HetimaToken.fromString(HetimaToken.tkComment, comment));
            }).catchError((e) {
              return commentShort();
            }).then((List<int> comment) {
              completer.complete(new HetimaToken.fromList(HetimaToken.tkComment, comment));
            }).catchError((e) {
              completer.complete(new HetimaToken(HetimaToken.tkMinus));
            });
          }
          return;
        case 0x5b:
          {
          // "["
            _parser.back();
            _parser.pop();
            // "["
            longStringA().then((List<int> v) {
              completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
            }).catchError((e) {
              return longStringB().then((List<int> v) {
                completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
              });
            }).catchError((e) {
              completer.complete(new HetimaToken(HetimaToken.tkOpeingBracket));
            });
          }
          break;
        case 0x3d:
          // "="
          _parser.back();
          _parser.pop();
          _parser.readFromCommand((new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("=="))).done())
          .then((List<List<int>> v){
            completer.complete(new HetimaToken(HetimaToken.tkEqualEqual));
          }).catchError((e){
            completer.complete(new HetimaToken(HetimaToken.tkEqual));
          });

          break;
        case 0x3c:
          // <
          _parser.back();
          _parser.pop();
          
          List<hregex.RegexCommand> leftshift = (new hregex.RegexBuilder())
          .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("<<"))).done();
          List<hregex.RegexCommand> greterThanEqual = (new hregex.RegexBuilder())
          .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("<="))).done();

          _parser.readFromCommand(leftshift).then((List<List<int>> v){
            completer.complete(new HetimaToken(HetimaToken.tkLeftShift));
          }).catchError((e){
            _parser.readFromCommand(greterThanEqual).then((List<List<int>> v){
              completer.complete(new HetimaToken(HetimaToken.tkLessThanEqualSign));
            }).catchError((e){
              completer.complete(new HetimaToken(HetimaToken.tkLessThanSign));
            });
          });
          break;
        case 0x3e:
          // > 
          _parser.back();
          _parser.pop();
          
          List<hregex.RegexCommand> leftshift = (new hregex.RegexBuilder())
          .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(">>"))).done();
          List<hregex.RegexCommand> greterThanEqual = (new hregex.RegexBuilder())
          .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(">="))).done();

          _parser.readFromCommand(leftshift).then((List<List<int>> v){
            completer.complete(new HetimaToken(HetimaToken.tkRightShift));
          }).catchError((e){
            _parser.readFromCommand(greterThanEqual).then((List<List<int>> v){
              completer.complete(new HetimaToken(HetimaToken.tkGraterThanEqualSign));              
            }).catchError((e){
              completer.complete(new HetimaToken(HetimaToken.tkGraterThanSign));
            });
          });
          break;
        case 0x2f:
          // /
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkSlash));
          break;
        case 0x7e:
          // ~
          _parser.push();
          _parser.getPeek(1).then((List<int> v) {
            if(v[0] == 0x3d) {// =
              completer.complete(new HetimaToken(HetimaToken.tkNotEqual));
              _parser.pop();
            } else {
              completer.complete(new HetimaToken(HetimaToken.tkTilde));
              _parser.back();
              _parser.pop();
            }
          }).catchError((e){
            completer.completeError(e);
          });
          break;
        case 0x3a:
          // :
          _parser.push();
          _parser.getPeek(1).then((List<int> v) {
            if(v[0] == 0x3a) {// ::
              completer.complete(new HetimaToken(HetimaToken.tkDoubleColon));
              _parser.pop();
            } else {
              completer.complete(new HetimaToken(HetimaToken.tkColon));
              _parser.back();
              _parser.pop();
            }
          }).catchError((e){
            completer.completeError(e);
          });
          break;
        case 0x22: case 0x27: 
          // " '
          _parser.back();
          _parser.pop();
          normalString().then((List<int> v){
            completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));            
          }).catchError((e) {
            completer.completeError(e);
          });
          break;
        case 0x2e:
          // .
          _parser.push();
          _parser.readByte().then((int v){
            if(v == 0x2e) {
              _parser.readByte().then((int v){
                
              });
            } else if(0x30 <= v && v<=0x39){
              _parser.back();
              _parser.pop();
            } else {
              _parser.back();
              _parser.pop();
              completer.complete(new HetimaToken(HetimaToken.tkDot));
            }
          });
          break;
        case 0x30:case 0x31:case 0x32:case 0x33:case 0x34: 
        case 0x35:case 0x36:case 0x37:case 0x38:case 0x39:
          break;
        case 0xff:
          // -1
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

  async.Future<List<int>> normalString() {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    List<int> ret = [];
    loop(int s) {
     return _parser.readByte().then((int v) {
        if(v == 0x0a|| v == 0x0d) { // lf cr
          completer.completeError(new Exception());
          return;
        }
        else if(v==s) {
          completer.complete(ret);
          return;
        }
        else if(v== 0x5c) {// \
          _parser.readByte().then((int v) {
            switch(v) {
              case 0x61: //a 0x07
                ret.add(0x07);
                break;
              case 0x62: //b
                ret.add(0x08);
                break;
              case 0x66://f0x66 0x0c
                ret.add(0x0c);
                break;
              case 0x9e://n0x6e 0x0a
                ret.add(0x0a);
                break;
              //r0x72 0x0d
              case 0x72:
                ret.add(0x0d);
                break;
              //t0x74 0x09
              case 0x74:
                ret.add(0x09);
                break;
              //v0x76 0x0b
              case 0x76:
                ret.add(0x0b);
                break;
              case 0x5c://\0x5c 0x5c
                ret.add(0x5c);
                break;
              case 0x22://"0x22 0x22
                ret.add(0x22);
                break;
              case 0x27://'0x27 0x28
                ret.add(0x28);
                break;
              default:
                completer.complete(new Exception(""));
                return;
            }
            loop(s);
          }).catchError((e){
            completer.completeError(e);
          });
        }
        else {
          ret.add(v);
          loop(s);
        }
      }).catchError((e){
       completer.completeError(e);
     });
    }
    _parser.readByte().then((int s){
      return loop(s);
    }).catchError((e){
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
