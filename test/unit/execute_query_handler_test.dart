// ignore_for_file: strong_mode_implicit_dynamic_list_literal

library mysql1.test.unit.execute_query_handler_test;

import 'dart:convert';

import 'package:mockito/mockito.dart';

import 'package:mysql1/src/blob.dart';
import 'package:mysql1/src/prepared_statements/execute_query_handler.dart';

import 'package:mysql1/src/prepared_statements/prepared_query.dart';

import 'package:test/test.dart';

void main() {
  group('ExecuteQueryHandler.createNullMap', () {
    test('can build empty map', () {
      List<dynamic> list = List<dynamic>();
      var handler = new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals(list));
    });

    test('can build map with no nulls', () {
      List<dynamic> list = List<dynamic>(1);
      list[0] = 1;
      var handler = new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([0]));
    });

    test('can build map with one null', () {
      List<dynamic> list = List<dynamic>(1);
      list[0] = null;
      var handler = new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([1]));
    });

    test('can build map with eight nulls', () {
      List<dynamic> list = List<dynamic>(8);
      list[0] = null;
      list[1] = null;
      list[2] = null;
      list[3] = null;
      list[4] = null;
      list[5] = null;
      list[6] = null;
      list[7] = null;

      var handler = new ExecuteQueryHandler(
          null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([255]));
    });

    test('can build map with eight not nulls', () {
      List<dynamic> list = List<dynamic>(8);
      list[0] = 0;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = 0;

      var handler =
          new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([0]));
    });

    test('can build map with some nulls and some not', () {
      List<dynamic> list = List<dynamic>(8);
      list[0] = null;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      var handler =
          new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129]));
    });

    test('can build map with some nulls and some not', () {
      List<dynamic> list = List<dynamic>(8);
      list[0] = null;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      var handler =
          new ExecuteQueryHandler(null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129]));
    });

    test('can build map which is more than one byte', () {
      List<dynamic> list = List<dynamic>(16);
      list[0] = null;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      list[8] = 0;
      list[9] = 0;
      list[10] = 0;
      list[11] = 0;
      list[12] = 0;
      list[13] = 0;
      list[14] = 0;
      list[15] = 0;
      var handler = new ExecuteQueryHandler(
          null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129, 0]));
    });

    test('can build map which just is more than one byte', () {
      List<dynamic> list = List<dynamic>(9);
      list[0] = null;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      list[8] = 0;
  
      var handler = new ExecuteQueryHandler(
          null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129, 0]));
    });

    test('can build map which just is more than one byte with a null', () {
      List<dynamic> list = List<dynamic>(9);
      list[0] = null;
      list[1] = 0;
      list[2] = 0;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      list[8] = null;
      var handler = new ExecuteQueryHandler(
          null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129, 1]));
    });

    test(
        'can build map which just is more than one byte with a null, another pattern',
        () {
      List<dynamic> list = List<dynamic>(9);
      list[0] = null;
      list[1] = 0;
      list[2] = null;
      list[3] = 0;
      list[4] = 0;
      list[5] = 0;
      list[6] = 0;
      list[7] = null;
      list[8] = null;
      var handler = new ExecuteQueryHandler(
          null, false, list);
      var nullmap = handler.createNullMap();
      expect(nullmap, equals([129 + 4, 1]));
    });
  });

  group('ExecuteQueryHandler.writeValuesToBuffer', () {
    List<int> types;

    setUp(() {
      types = <int>[];
    });

    test('can write values for unexecuted query', () {
      var preparedQuery = new MockPreparedQuery();
      when(preparedQuery.statementHandlerId).thenReturn(123);

      var handler = new ExecuteQueryHandler(preparedQuery, false, List<dynamic>());
      handler.preparedValues = List<dynamic>();
      var buffer = handler.writeValuesToBuffer([], 0, types);
      expect(buffer.length, equals(11));
      expect(buffer.list, equals([23, 123, 0, 0, 0, 0, 1, 0, 0, 0, 1]));
    });

    test('can write values for executed query', () {
      var preparedQuery = new MockPreparedQuery();
      when(preparedQuery.statementHandlerId).thenReturn(123);

      var handler = new ExecuteQueryHandler(preparedQuery, true, List<dynamic>());
      handler.preparedValues = List<dynamic>();
      var buffer = handler.writeValuesToBuffer([], 0, types);
      expect(buffer.length, equals(11));
      expect(buffer.list, equals([23, 123, 0, 0, 0, 0, 1, 0, 0, 0, 0]));
    });

    test('can write values for executed query with nullmap', () {
      var preparedQuery = new MockPreparedQuery();
      when(preparedQuery.statementHandlerId).thenReturn(123);

      var handler = new ExecuteQueryHandler(preparedQuery, true, List<dynamic>());
      handler.preparedValues = List<dynamic>();
      var buffer = handler.writeValuesToBuffer([5, 6, 7], 0, types);
      expect(buffer.length, equals(14));
      expect(
          buffer.list, equals([23, 123, 0, 0, 0, 0, 1, 0, 0, 0, 5, 6, 7, 0]));
    });

    test('can write values for unexecuted query with values', () {
      var preparedQuery = new MockPreparedQuery();
      when(preparedQuery.statementHandlerId).thenReturn(123);

      types = [100];
      List<dynamic> list = List<dynamic>(1);
      list[0] = 123;
      var handler = new ExecuteQueryHandler(preparedQuery, false, list);
      handler.preparedValues = list;
      var buffer = handler.writeValuesToBuffer([5, 6, 7], 8, types);
      expect(buffer.length, equals(23));
      expect(
          buffer.list,
          equals([
            23,
            123,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            5,
            6,
            7,
            1,
            100,
            123,
            0,
            0,
            0,
            0,
            0,
            0,
            0
          ]));
    });
  });

  group('ExecuteQueryHandler.prepareValue', () {
    MockPreparedQuery preparedQuery;
    ExecuteQueryHandler handler;

    setUp(() {
      preparedQuery = new MockPreparedQuery();
      handler = new ExecuteQueryHandler(preparedQuery, false, List<dynamic>());
    });

    test('can prepare int values correctly', () {
      expect(handler.prepareValue(123), equals(123));
    });

    test('can prepare string values correctly', () {
      expect(handler.prepareValue("hello"), equals(utf8.encode("hello")));
    });

    test('can prepare double values correctly', () {
      expect(handler.prepareValue(123.45), equals(utf8.encode("123.45")));
    });

    test('can prepare datetime values correctly', () {
      var dateTime = new DateTime.utc(2014, 3, 4, 5, 6, 7, 8);
      expect(handler.prepareValue(dateTime), equals(dateTime));
    });

    test('can prepare bool values correctly', () {
      expect(handler.prepareValue(true), equals(true));
    });

    test('can prepare list values correctly', () {
      expect(handler.prepareValue([1, 2, 3]), equals([1, 2, 3]));
    });

    test('can prepare blob values correctly', () {
      expect(handler.prepareValue(new Blob.fromString("hello")),
          equals(utf8.encode("hello")));
    });
  });

  group('ExecuteQueryHandler._measureValue', () {
    MockPreparedQuery preparedQuery;
    ExecuteQueryHandler handler;

    setUp(() {
      preparedQuery = new MockPreparedQuery();
      handler = new ExecuteQueryHandler(preparedQuery, false, List<dynamic>());
    });

    test('can measure int values correctly', () {
      expect(handler.measureValue(123, [123]), equals(8));
    });

    test('can measure short string correctly', () {
      var string = "a";
      var preparedString = utf8.encode(string);
      expect(handler.measureValue(string, preparedString), equals(2));
    });

    test('can measure longer string correctly', () {
      var string = new String.fromCharCodes(new List.filled(300, 65));
      var preparedString = utf8.encode(string);
      expect(handler.measureValue(string, preparedString),
          equals(3 + string.length));
    });

    test('can measure even longer string correctly', () {
      var string = new String.fromCharCodes(new List.filled(70000, 65));
      var preparedString = utf8.encode(string);
      expect(handler.measureValue(string, preparedString),
          equals(4 + string.length));
    });

//    test('can measure even very long string correctly', () {
//      var string = new String.fromCharCodes(new List.filled(2 << 23 + 1, 65));
//      var preparedString = utf8.encode(string);
//      expect(handler.measureValue(string, preparedString),
//          equals(5 + string.length));
//    });

    //etc
  });
}

class MockPreparedQuery extends Mock implements PreparedQuery {}
