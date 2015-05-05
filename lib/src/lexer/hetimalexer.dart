part of hetimascript;

class HetimaLexer {
  List<HetimaToken> tokenList = [];
  hregex.RegexEasyParser _parser = null;
  HetimaTokenHelper _helper = new HetimaTokenHelper();

  HetimaLexer.create(heti.HetimaBuilder builder) {
    _parser = new hregex.RegexEasyParser(builder);
  }

  // " " "\f" "\t" "\v"
  static final List<int> spaceSign = [0x20, 0x0c, 0x09, 0x0b];
  static final List<int> crlfSign = [0x0a, 0x0d];
  static final List<int> numberBeginSign = [0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39];

  //
  async.Future<HetimaToken> lexer() {
    async.Completer<HetimaToken> completer = new async.Completer();
    _parser.push();
    _parser.readByte().then((int v) {
      if (spaceSign.contains(v)) {      
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkSpace));
        return;
      } else if(crlfSign.contains(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkCrlf));
        return;
      } else if(numberBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        number().then((int num) {
          completer.complete(new HetimaToken.fromNumber(HetimaToken.tkNumber, v));
        }).catchError((e) {
          completer.completeError(new Exception());
        });
        return;
      }

      switch (v) {
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
          _parser.readFromCommand((new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("=="))).done()).then((List<List<int>> v) {
            completer.complete(new HetimaToken(HetimaToken.tkEqualEqual));
          }).catchError((e) {
            completer.complete(new HetimaToken(HetimaToken.tkEqual));
          });

          break;
        case 0x3c:
          // <
          _parser.back();
          _parser.pop();

          List<hregex.RegexCommand> leftshift = (new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("<<"))).done();
          List<hregex.RegexCommand> greterThanEqual = (new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("<="))).done();

          _parser.readFromCommand(leftshift).then((List<List<int>> v) {
            completer.complete(new HetimaToken(HetimaToken.tkLeftShift));
          }).catchError((e) {
            _parser.readFromCommand(greterThanEqual).then((List<List<int>> v) {
              completer.complete(new HetimaToken(HetimaToken.tkLessThanEqualSign));
            }).catchError((e) {
              completer.complete(new HetimaToken(HetimaToken.tkLessThanSign));
            });
          });
          break;
        case 0x3e:
          // >
          _parser.back();
          _parser.pop();

          List<hregex.RegexCommand> leftshift = (new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(">>"))).done();
          List<hregex.RegexCommand> greterThanEqual = (new hregex.RegexBuilder()).addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(">="))).done();

          _parser.readFromCommand(leftshift).then((List<List<int>> v) {
            completer.complete(new HetimaToken(HetimaToken.tkRightShift));
          }).catchError((e) {
            _parser.readFromCommand(greterThanEqual).then((List<List<int>> v) {
              completer.complete(new HetimaToken(HetimaToken.tkGraterThanEqualSign));
            }).catchError((e) {
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
            if (v[0] == 0x3d) {
              // =
              completer.complete(new HetimaToken(HetimaToken.tkNotEqual));
              _parser.pop();
            } else {
              completer.complete(new HetimaToken(HetimaToken.tkTilde));
              _parser.back();
              _parser.pop();
            }
          }).catchError((e) {
            completer.completeError(e);
          });
          break;
        case 0x3a:
          // :
          _parser.push();
          _parser.getPeek(1).then((List<int> v) {
            if (v[0] == 0x3a) {
              // ::
              completer.complete(new HetimaToken(HetimaToken.tkDoubleColon));
              _parser.pop();
            } else {
              completer.complete(new HetimaToken(HetimaToken.tkColon));
              _parser.back();
              _parser.pop();
            }
          }).catchError((e) {
            completer.completeError(e);
          });
          break;
        case 0x22:
        case 0x27:
          // " '
          _parser.back();
          _parser.pop();
          normalString().then((List<int> v) {
            completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
          }).catchError((e) {
            completer.completeError(e);
          });
          break;
        case 0x2e:
          // .
          _parser.push();
          _parser.readByte().then((int v) {
            if (v == 0x2e) {
              _parser.push();
              hregex.RegexBuilder b = new hregex.RegexBuilder().addRegexCommand(new hregex.CharCommand.createFromList([0x2e]));
              _parser.readFromCommand(b.done()).then((List<List<int>> v) {
                completer.complete(new HetimaToken(HetimaToken.tkDots));
                _parser.pop();
                _parser.pop();
                _parser.pop();
              }).catchError((e) {
                _parser.back();
                _parser.pop();
                _parser.pop();
                _parser.pop();
                completer.complete(new HetimaToken(HetimaToken.tkConcat));
              });
            } else if (0x30 <= v && v <= 0x39) {
              // todo
              _parser.back();
              _parser.pop();
              _parser.back();
              _parser.pop();

              _parser.push();
              number().then((num v) {
                completer.complete(new HetimaToken.fromNumber(HetimaToken.tkNumber, v));
                _parser.pop();
              }).catchError((e) {
                completer.completeError(new Exception());
                _parser.back();
                _parser.pop();
              });
            } else {
              _parser.back();
              _parser.pop();
              _parser.pop();
              completer.complete(new HetimaToken(HetimaToken.tkDot));
            }
          }).catchError((e) {
            _parser.pop();
            completer.complete(new HetimaToken(HetimaToken.tkDot));
          });
          break;
        case 0x2b:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkPulus));
          break;
        case 0x2a:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkAsterisk));
          break;
        case 0x2f:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkSlash));
          break;
        case 0x25:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkPercent));
          break;
        case 0x5e:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkCaret));
          break;
        case 0x23:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkHashMark));
          break;
        case 0x28:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkLeftParen));
          break;
        case 0x29:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkRightParen));
          break;
        case 0x7b:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkLeftBrace));
          break;
        case 0x7d:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkRightBrace));
          break;
        case 0x5b:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkRightBracket));
          break;
        case 0x5d:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkRightBracket));
          break;
        case 0x3b:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkSemicolon));
          break;
        case 0x2c:
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkSemicolon));
          break;
        case 0x30:
        case 0x31:
        case 0x32:
        case 0x33:
        case 0x34:
        case 0x35:
        case 0x36:
        case 0x37:
        case 0x38:
        case 0x39:
        case 0x61:
        case 0x62:
        case 0x63:
        case 0x64:
        case 0x65:
        case 0x66:
        case 0x67:
        case 0x68:
        case 0x69:
        case 0x6a:
        case 0x6b:
        case 0x6c:
        case 0x6d:
        case 0x6e:
        case 0x6f:
        case 0x70:
        case 0x71:
        case 0x72:
        case 0x72:
        case 0x74:
        case 0x75:
        case 0x76:
        case 0x77:
        case 0x78:
        case 0x79:
        case 0x7a:
        case 0x41:
        case 0x42:
        case 0x43:
        case 0x44:
        case 0x45:
        case 0x46:
        case 0x47:
        case 0x48:
        case 0x49:
        case 0x4a:
        case 0x4b:
        case 0x4c:
        case 0x4d:
        case 0x4e:
        case 0x4f:
        case 0x50:
        case 0x51:
        case 0x52:
        case 0x52:
        case 0x54:
        case 0x55:
        case 0x56:
        case 0x57:
        case 0x58:
        case 0x59:
        case 0x5a:
          _parser.back();
          _parser.pop();
          name().then((List<int> v) {
            completer.complete(new HetimaToken.fromList(HetimaToken.tkName, v));
          }).catchError((e) {
            completer.completeError(new Exception());
          });
          break;
        case 0xff:
          // -1
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkEOF));
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

  async.Future<List<int>> name() {
    return _helper.name(_parser);
  }

  async.Future<String> commentLong() {
    return _helper.commentLong(_parser);
  }

  async.Future<List<int>> commentShort() {
    return _helper.commentShort(_parser);
  }

  async.Future<num> number() {
    return _helper.number(_parser);
  }

  async.Future<List<int>> normalString() {
    return _helper.normalString(_parser);
  }

  async.Future<List<int>> longStringA() {
    return _helper.longStringA(_parser);
  }

  async.Future<List<int>> longStringB() {
    return _helper.longStringB(_parser);
  }
}
