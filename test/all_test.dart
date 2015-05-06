// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dart_hetimascript.test;

import 'package:unittest/unittest.dart';
import 'package:hetimascript/hetimascript.dart';
import 'test_lexer.dart' as hetimascript_00;
import 'test_parser.dart' as test_parser;

main() {
  hetimascript_00.script00();
  hetimascript_00.script01();
  test_parser.script00();
}
