part of hetimascript;


class HetimaObject {}

class HetimaFunction extends HetimaObject {
  void act(List<HetimaObject> args) {}
}

class NumberObject extends HetimaObject {}
class StringObject extends HetimaObject {}

class PrintFunction extends HetimaObject {
  PrintFunction();
  void act(List<HetimaObject> args) {
    StringBuffer buffer = new StringBuffer();
    for (HetimaObject o in args) {
      buffer.write(o.toString());
    }
    print(buffer.toString());
  }
}

class ObjectManager {
  Map<String, HetimaObject> map = {};
  ObjectManager() {
    map["print"] = new PrintFunction();
  }
}
