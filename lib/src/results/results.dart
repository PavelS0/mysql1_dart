part of results;

/**
 * Holds query results.
 */
abstract class Results {
  Stream<Row> get stream;
  List<Row> get rows;

  /**
   * The id of the inserted row, or [null] if no row was inserted.
   */
  int get insertId;

  /**
   * The number of affected rows in an update statement, or
   * [null] in other cases.
   */
  int get affectedRows;

  /**
   * A list of the fields returned by the query.
   */
  List<Field> get fields;

 /**
  * If this [Results] object contains a stream, converts the stream to a list
  * and returns the new [Results] object in the future.
  */
  Future<Results> toList();
}
