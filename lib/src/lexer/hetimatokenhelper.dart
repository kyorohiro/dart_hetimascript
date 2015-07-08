library hetimascript.helper;

import 'package:hetimacore/hetimacore.dart' as heti;
import 'package:hetimaregex/hetimaregex.dart' as hregex;
import 'dart:convert' as conv;
import 'dart:async' as async;


class HetimaTokenHelper {
  async.Future<num> number(hregex.RegexEasyParser _parser) {
    async.Completer<int> completer = new async.Completer();
    hexNumber(_parser).then((num v){
      completer.complete(v);
    }).catchError((e){
      normalNumber(_parser).then((num v){
        completer.complete(v);
      }).catchError((e){
        completer.completeError(e);
      });
    });
    return completer.future;
  }

  async.Future<num> normalNumber(hregex.RegexEasyParser _parser) {
    async.Completer<int> completer = new async.Completer();
    hregex.RegexBuilder number = new hregex.RegexBuilder();
    number
        .push(true)
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("+")))
        .or()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("-")))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.MatchByteCommand([0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39])))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .push(true)
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(".")))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.MatchByteCommand([0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39])))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop();

    _parser.push();
    _parser.readFromCommand(number.done()).then((List<List<int>> v) {
      if (v.length != 4 || (v[0].length == 0 && v[1].length == 0 && v[3].length == 0)) {
        _parser.back();
        _parser.pop();
        completer.completeError(new Exception());
        return;
      }
      List<int> ret = [];
      ret.addAll(v[1]);
      ret.addAll(v[2]);
      ret.addAll(v[3]);
      String d = conv.UTF8.decode(ret);
      num retV = num.parse(d);
      if (v[0] == 0x2d) {
        retV = -1 * retV;
      }

      _parser.pop();
      completer.complete(retV);
    }).catchError((e) {
      _parser.back();
      _parser.pop();
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<num> hexNumber(hregex.RegexEasyParser _parser) {
    async.Completer<int> completer = new async.Completer();
    hregex.RegexBuilder hexNumber = new hregex.RegexBuilder();
    hexNumber
        .push(true)
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("+")))
        .or()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("-")))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("0x")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(
            new hregex.MatchByteCommand([0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46])))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .push(true)
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode(".")))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop()
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(
            new hregex.MatchByteCommand([0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46])))
        .or()
        .addRegexCommand(new hregex.EmptyCommand())
        .pop();

    _parser.readFromCommand(hexNumber.done()).then((List<List<int>> v) {
      if (v.length != 4 || (v[0].length == 0 && v[1].length == 0 && v[3].length == 0)) {
        completer.completeError(new Exception());
        return;
      }

      int integerPart = 0;
      {
        if (v[1].length == 0) {} else {
          List<int> ret = [];
          ret.addAll(conv.UTF8.encode("0x"));
          ret.addAll(v[1]);
          integerPart = num.parse(conv.UTF8.decode(ret));
        }
      }
      int decimalPart = 0;
      {
        if (v[3].length == 0) {} else {
          List<int> ret = [];
          ret.addAll(conv.UTF8.encode("0x"));
          ret.addAll(v[3]);
          decimalPart = num.parse(conv.UTF8.decode(ret));
        }
      }
      String numberPart =  "";
      if(v[2].length == 0) {
        numberPart = integerPart.toString();
      } else {
        numberPart = integerPart.toString() + "." + decimalPart.toString();        
      }
      num retV = num.parse(numberPart);
      if (v[0] == 0x2d) {
        retV = -1 * retV;
      }
      completer.complete(retV);
    }).catchError((e) {
      completer.completeError(new Exception());      
    });
    return completer.future;
  }

  async.Future<List<int>> shortString(hregex.RegexEasyParser _parser) {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    List<int> ret = [];
    loop(int s) {
      return _parser.readByte().then((int v) {
        if (v == 0x0a || v == 0x0d) {
          // lf cr
          completer.completeError(new Exception());
          return;
        } else if (v == s) {
          completer.complete(ret);
          return;
        } else if (v == 0x5c) {
          // \
          _parser.readByte().then((int v) {
            switch (v) {
              case 0x61: //a 0x07
                ret.add(0x07);
                break;
              case 0x62: //b
                ret.add(0x08);
                break;
              case 0x66: //f0x66 0x0c
                ret.add(0x0c);
                break;
              case 0x9e: //n0x6e 0x0a
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
              case 0x5c: //\0x5c 0x5c
                ret.add(0x5c);
                break;
              case 0x22: //"0x22 0x22
                ret.add(0x22);
                break;
              case 0x27: //'0x27 0x28
                ret.add(0x28);
                break;
              default:
                completer.complete(new Exception(""));
                return;
            }
            loop(s);
          }).catchError((e) {
            completer.completeError(e);
          });
        } else {
          ret.add(v);
          loop(s);
        }
      }).catchError((e) {
        completer.completeError(e);
      });
    }
    _parser.readByte().then((int s) {
      return loop(s);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<int>> longString(hregex.RegexEasyParser _parser) {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    hregex.RegexBuilder patternA = new hregex.RegexBuilder();
    patternA
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("[[")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UncharacterCommand(conv.UTF8.encode("]]"))))
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("]]")));
    hregex.RegexBuilder patternB = new hregex.RegexBuilder();
    patternB
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("[==[")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UncharacterCommand(conv.UTF8.encode("]==]"))))
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("]==]")));
    
    _parser.readFromCommand(patternA.done()).then((List<List<int>> v) {
      _parser.pop();
      completer.complete(v[0]);
    }).catchError((e) {
      _parser.readFromCommand(patternB.done()).then((List<List<int>> v) {
        _parser.pop();
        completer.complete(v[0]);
      }).catchError((e){
        _parser.back();
        _parser.pop();
        completer.completeError(e);        
      });
    });
    return completer.future;
  }


  async.Future<List<int>> name(hregex.RegexEasyParser _parser) {
    async.Completer<List<int>> completer = new async.Completer();
    hregex.RegexBuilder name = new hregex.RegexBuilder();
    name.push(true)
   .addRegexCommand(new hregex.MatchByteCommand(
    [0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
     0x70,0x71,0x72,0x72,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,
     0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
     0x50,0x51,0x52,0x52,0x54,0x55,0x56,0x57,0x58,0x59,0x5a]))
    .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.MatchByteCommand(
        [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
         0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f,
         0x70,0x71,0x72,0x72,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,
         0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
         0x50,0x51,0x52,0x52,0x54,0x55,0x56,0x57,0x58,0x59,0x5a])))
    .pop();
    _parser.push();
    _parser.readFromCommand(name.done()).then((List<List<int>> v){
      _parser.pop();
      completer.complete(v[0]);
    }).catchError((e){
      _parser.back();
      _parser.pop();
      completer.completeError(e);
    });
    return completer.future;
  }
  
  async.Future<List<int>> comment(hregex.RegexEasyParser _parser) {
    async.Completer<List<int>> completer = new async.Completer();
    _parser.push();
    hregex.RegexBuilder longComment = new hregex.RegexBuilder();
    longComment
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("--[[")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UncharacterCommand(conv.UTF8.encode("]]"))))
        .pop()
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("]]")));
    hregex.RegexBuilder shortComment = new hregex.RegexBuilder();
    shortComment
        .addRegexCommand(new hregex.CharCommand.createFromList(conv.UTF8.encode("--")))
        .push(true)
        .addRegexLeaf(new hregex.StarPattern.fromCommand(new hregex.UnmatchByteCommand(conv.UTF8.encode("\r\n\0"))))
        .pop();
    
    _parser.readFromCommand(longComment.done()).then((List<List<int>> v) {
      _parser.pop();
      completer.complete(v[0]);
    }).catchError((e) {
      _parser.readFromCommand(shortComment.done()).then((List<List<int>> v){
        completer.complete(v[0]);
        _parser.pop();          
      }).catchError((e){
        _parser.back();
        _parser.pop();
        completer.completeError(e);        
      });
    });
    return completer.future;
  }


}

