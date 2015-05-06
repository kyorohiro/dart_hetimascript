part of hetimascript;

class HetimaParser {
  HetimaLexer _lexer = null;

  HetimaParser.create(HetimaLexer lexer) {
    this._lexer = lexer;
  }

  async.Future<int>execute(HetimaLexer lexer) {
    async.Completer<int> c = new async.Completer();
    grammerStat(lexer, c);
    return c.future;
  }
  
  async.Future grammerVar() {
    return null;
  }

  void grammerStat(HetimaLexer lexer, async.Completer<int> c) {
    grammerVar().then((e){
      return lexer.next();
    }).then((HetimaToken v){
      if(v == HetimaToken.tkEqual) {
        return lexer.next();
      } else {
        throw new Exception("");
      }
    }).then((HetimaToken v){
      
    });
     
    lexer.next().then((HetimaToken t) {
      switch(t.kind) {
        case HetimaToken.tkComment:
        c.complete(0);
        break;
        case HetimaToken.tkName:
      }
    });
  }
}

