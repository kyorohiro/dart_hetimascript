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

    //
    //
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
      } else if (HetimaToken.stringBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        normalString().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
        }).catchError((e) {
          completer.completeError(e);
        });
        return;
      } else if (0x2d == v) {
        // "-"
        _parser.back();
        _parser.pop();
        comment().then((List<int> comment) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkComment, comment));
        }).catchError((e) {
          _parser.resetIndex(_parser.getInedx() + 1);
          completer.complete(new HetimaToken(HetimaToken.tkMinus));
        });
        return;
      } else if (0x5b == v) {
        // "["
        _parser.back();
        _parser.pop();
        // "["
        longString().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
        }).catchError((e) {
          _parser.resetIndex(_parser.getInedx() + 1);
          completer.complete(new HetimaToken(HetimaToken.tkOpeingBracket));
        });
        return;
      }

      switch (v) {
        case 0x3d:
          _parser.pop();
          _matchFromNextChar(<int, int>{0x3d:HetimaToken.tkEqualEqual}, HetimaToken.tkEqual, _parser, completer);
          break;
        case 0x3c:
          // <
          _parser.pop();
          _matchFromNextChar(<int, int>{0x3c: HetimaToken.tkLeftShift, 0x3d:HetimaToken.tkLessThanEqualSign}, HetimaToken.tkLessThanSign, _parser, completer);
          break;
        case 0x3e:
          // >
          _parser.pop();
          _matchFromNextChar(<int, int>{0x3e: HetimaToken.tkRightShift, 0x3d:HetimaToken.tkGraterThanEqualSign}, HetimaToken.tkGraterThanSign, _parser, completer);
          break;
        case 0x7e:
          // ~
          _parser.pop();
          _matchFromNextChar(<int, int>{0x3d: HetimaToken.tkNotEqual}, HetimaToken.tkTilde, _parser, completer);
          break;
        case 0x3a:
          // :
          _parser.pop();
          _matchFromNextChar(<int, int>{0x3a:HetimaToken.tkDoubleColon}, HetimaToken.tkColon, _parser, completer);
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

  void _matchFromNextChar(Map<int, int> expectIfFound, int expectIfNotFound, hregex.RegexEasyParser _parser, async.Completer<HetimaToken> completer) {
    _parser.push();
    _parser.readByte().then((int w) {
      if (expectIfFound.containsKey(w)) {
        completer.complete(new HetimaToken(expectIfFound[w]));
        _parser.pop();
      } else {
        completer.complete(new HetimaToken(expectIfNotFound));
        _parser.back();
        _parser.pop();
      }
    }).catchError((e) {
      //<
      completer.complete(new HetimaToken(expectIfNotFound));
      _parser.back();
      _parser.pop();
    });
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
