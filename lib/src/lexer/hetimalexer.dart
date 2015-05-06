part of hetimascript;

class HetimaLexer {
  List<HetimaToken> tokenList = [];
  hregex.RegexEasyParser _parser = null;
  HetimaTokenHelper _helper = new HetimaTokenHelper();

  HetimaLexer.create(heti.HetimaBuilder builder) {
    _parser = new hregex.RegexEasyParser(builder);
  }

  HetimaLexer.fromString(String text) {
    _parser = new hregex.RegexEasyParser(new heti.ArrayBuilder.fromList(conv.UTF8.encode(text)));
  }

  //
  async.Future<HetimaToken> next() {
    async.Completer<HetimaToken> completer = new async.Completer();
    loop() {
      return lexer().then((HetimaToken v) {
        if(v.kind == HetimaToken.tkSpace || v.kind == HetimaToken.tkComment) {
          return loop();
        } else {
          completer.complete(v);
        }
      }).catchError((e){
        completer.completeError(e);
      });
    }
    ;
    loop();
    return completer.future;
  }
  async.Future<HetimaToken> lexer() {
    async.Completer<HetimaToken> completer = new async.Completer();
    _parser.push();
    _parser.readByte().then((int v) {
      if (HetimaToken.spaceSign.contains(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkSpace));
      } else if (HetimaToken.crlfSign.contains(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.tkCrlf));
      } else if (HetimaToken.numberBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        number().then((int num) {
          completer.complete(new HetimaToken.fromNumber(HetimaToken.tkNumber, v));
        }).catchError((e) {
          completer.completeError(new Exception());
        });
      } else if (HetimaToken.nameBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        name().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkName, v));
        }).catchError((e) {
          completer.completeError(new Exception());
        });
      } else if (HetimaToken.singleConvertMap.containsKey(v)) {
        _parser.pop();
        completer.complete(new HetimaToken(HetimaToken.singleConvertMap[v]));
      } else if (HetimaToken.stringBeginSign.contains(v)) {
        _parser.back();
        _parser.pop();
        normalString().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
        }).catchError((e) {
          completer.completeError(e);
        });
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
      } else if (0x5b == v) {
        // "["
        _parser.back();
        _parser.pop();
        longString().then((List<int> v) {
          completer.complete(new HetimaToken.fromList(HetimaToken.tkString, v));
        }).catchError((e) {
          _parser.resetIndex(_parser.getInedx() + 1);
          completer.complete(new HetimaToken(HetimaToken.tkOpeingBracket));
        });
      } else if (0x3d == v) {
        // =
        _parser.pop();
        _matchFromNextChar(<int, int>{0x3d: HetimaToken.tkEqualEqual}, HetimaToken.tkEqual, _parser, completer);
      } else if (0x3c == v) {
        // <
        _parser.pop();
        _matchFromNextChar(<int, int>{0x3c: HetimaToken.tkLeftShift, 0x3d: HetimaToken.tkLessThanEqualSign}, HetimaToken.tkLessThanSign, _parser, completer);
      } else if (0x3e == v) {
        // >
        _parser.pop();
        _matchFromNextChar(<int, int>{0x3e: HetimaToken.tkRightShift, 0x3d: HetimaToken.tkGraterThanEqualSign}, HetimaToken.tkGraterThanSign, _parser, completer);
      } else if (0x7e == v) {
        // ~
        _parser.pop();
        _matchFromNextChar(<int, int>{0x3d: HetimaToken.tkNotEqual}, HetimaToken.tkTilde, _parser, completer);
      } else if (0x3a == v) {
        // :
        _parser.pop();
        _matchFromNextChar(<int, int>{0x3a: HetimaToken.tkDoubleColon}, HetimaToken.tkColon, _parser, completer);
      } else if (0x2e == v) {
        // .
        hregex.RegexBuilder b = new hregex.RegexBuilder().push(true)
            //.([0-9])
            .addRegexCommand(new hregex.MatchByteCommand([0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39]))
            // ...
            .or().addRegexCommand(new hregex.CharCommand.createFromList([0x2e, 0x2e]))
            // ..
            .or().addRegexCommand(new hregex.CharCommand.createFromList([0x2e]));

        _parser.readFromCommand(b.done()).then((List<List<int>> w) {
          if (w[0].length == 0) {
            _parser.pop();
            completer.complete(new HetimaToken(HetimaToken.tkDot));
          } else if (w[0].length == 1) {
            if (0x30 <= w[0][0] && w[0][0] <= 0x39) {
              // number
              _parser.back();
              _parser.pop();
              number().then((v) {
                completer.complete(new HetimaToken.fromNumber(HetimaToken.tkNumber, v));
              });
            } else {
              _parser.pop();
              completer.complete(new HetimaToken(HetimaToken.tkConcat));
            }
          } else if (w[0].length == 2) {
            _parser.pop();
            completer.complete(new HetimaToken(HetimaToken.tkDots));
          }
        }).catchError((e) {
          _parser.pop();
          completer.complete(new HetimaToken(HetimaToken.tkDot));
        });
      } else {
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
