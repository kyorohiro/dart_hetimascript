// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dart_hetimacore.test;

import 'package:unittest/unittest.dart';
import 'package:hetimacore/hetimacore.dart';
import 'test_hetimacore_00.dart' as core00;
main() {
  group('A group of tests', () {
    setUp(() {
    });
    test('First Test', () {
      core00.script00();
    });
  });
}
