part of hetimascript;

class HetimaLexer {
  List<HetimaToken> tokenList = [];
  hregex.RegexEasyParser _parser = null;
  HetimaTokenHelper _helper = new HetimaTokenHelper();

  HetimaLexer.create(heti.HetimaBuilder builder) {
    _parser = new hregex.RegexEasyParser(builder);
  }

  //
  async.Future<HetimaToken> lexer() {
    async.Completer<HetimaToken> completer = new async.Completer();
    _parser.push();
    _parser.readByte().then((int v) {
      if (HetimaToken.spaceSign.contains(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkSpace));
        return;
      } else if (HetimaToken.crlfSign.contains(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkCrlf));
        return;
      } else if (HetimaToken.numberBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        number().then((int num) {
          completer.complete(new HetimaToken.fromNumber(HetimaToken.tkNumber, v));
        }).catchError((e) {
          completer.completeError(new Exception());
        });
        return;
      } else if (HetimaToken.nameBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        name().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkName, v));
        }).catchError((e) {
          completer.completeError(new Exception());
        });
        return;
      } else if (HetimaToken.singleConvertMap.containsKey(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.singleConvertMap[v]));
        return;
      }

      switch (v) {
        case 0x2d: // "-"
          _parser.back();
          _parser.pop();
          comment().then((List<int> comment) {
            completer.complete(new HetimaToken.fromList(HetimaToken.tkComment, comment));
          }).catchError((e) {
            _parser.resetIndex(_parser.getInedx() + 1);
            completer.complete(new HetimaToken(HetimaToken.tkMinus));
          });
          return;
        case 0x5b:
          {
            // "["
            _parser.back();
            _parser.pop();
            // "["
            longString().then((List<int> v) {
              completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
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

  async.Future<List<int>> comment() {
    return _helper.comment(_parser);
  }

  async.Future<num> number() {
    return _helper.number(_parser);
  }

  async.Future<List<int>> normalString() {
    return _helper.shortString(_parser);
  }

  async.Future<List<int>> longString() {
    return _helper.longString(_parser);
  }
}
