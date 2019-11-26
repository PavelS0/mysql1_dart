/*
import 'dart:async';
import 'dart:collection';
import 'single_connection.dart';
import 'package:pool/pool.dart';




class PooledConnection  {
  final ConnectionPool _pool;
  final DateTime _collectTime;
  final MySqlConnection _conn;
  PooledConnection._() : _collectTime = DateTime.now() {
  }
  
  void returnToPool() {

  } 
}

class ConnectionPool {
  final ConnectionSettings settings;
  final int maxConnections;
  final Duration collectPeriod;

  ListQueue <_PoolItem> _list = ListQueue();

  ConnectionPool (this.settings, {this.collectPeriod = const Duration (minutes: 1), this.maxConnections = 4}) {

  }

  Future _reconnect (_PoolItem it) async {
    it.conn = await MySqlConnection.connect(settings);
    it.collectTime = DateTime.now();
  }

  Future<PooledConnection> _connect () async {
    PooledConnection conn = PooledConnection();
    conn._collectTime = DateTime.now();
    conn._conn = await MySqlConnection.connect(settings);
    return conn;
  }

  Future<MySqlConnection> employ() async {
    DateTime now = DateTime.now();
    MySqlConnection conn;
    Iterator<_PoolItem> it = _list.iterator;
    while (it.moveNext() && !it.current.conn.isIdle);
    if (it.current == null) {
      if (_list.length < maxConnections) {
        _list.add(await _connect());
      } else {
        //TODO: maybe await? for any completed
      }
    } else {
      if (now.difference(it.current.collectTime) > collectPeriod) {
        await _reconnect(it.current);
      } else {
        bool ping = await it.current.conn.ping();
        if (!ping) {
           await _reconnect(it.current);
        }
      }
    }
    return conn;
  }

  void close() {


  }
}


PROCEDURE NewPool* (dir: Directory; IN connectPar: ANYREC; IN par: PoolPar): Pool;
		VAR p: Pool;
	BEGIN
		NEW(p);
		p.dir := dir;
		p.dbPar := KrlMeta.NewAs(connectPar);
		KrlMeta.CopyRec(connectPar, p.dbPar);
		KrlMeta.CopyRec(par, p.par);
	RETURN p
	END NewPool;

	PROCEDURE ^ (p: Pool) Collect*, NEW;

	PROCEDURE (p: Pool) EmployLong* (VAR db: Database; duration: INTEGER), NEW;
		VAR it: PoolItem;
	BEGIN
		ASSERT(db = NIL, 20);
		p.Collect;
		IF p.empN < p.par.maxEmployedN THEN
			IF p.free # NIL THEN
				it := p.free;
				p.free := it.next;
				IF it.next # NIL THEN
					it.next.prev := NIL
				END;
				it.next := NIL;
				it.free := FALSE;
				DEC(p.freeN);
				db := it.db
			ELSE
				IF items # NIL THEN
					it := items;
					items := it.next
				ELSE
					NEW(it)
				END;
				it.db := p.dir.Connect(p.dbPar);
				it.pool := p;
				it.t := Lf.TimeMs() + duration + p.par.collectTime;
				db := it.db;
				db.it := it
			END;
			it.next := p.emp;
			IF p.emp # NIL THEN
				p.emp.prev := it
			END;
			INC(p.empN);
			p.emp := it;
			db.OnEmploy(duration);
			db := it.db
		END
	END EmployLong;

	PROCEDURE (p: Pool) Employ* (VAR db: Database), NEW;
	BEGIN
		p.EmployLong(db, p.par.duration)
	END Employ;

	PROCEDURE (p: Pool) EmployedN* (): INTEGER, NEW;
	BEGIN
	RETURN p.empN
	END EmployedN;

	PROCEDURE (p: Pool) FreeN* (): INTEGER, NEW;
	BEGIN
	RETURN p.freeN
	END FreeN;

	PROCEDURE (db: Database) ReturnToPool*, NEW;
		VAR p: Pool; it: PoolItem;
	BEGIN
		ASSERT(db.it # NIL, 20);
		p := db.it.pool;
		it := db.it;
		ASSERT(~db.it.free, 21);
		IF db.Uncommited() THEN
			db.Rollback
		END;
		db.OnFree;
		IF it.prev # NIL THEN
			it.prev.next := it.next
		ELSE
			p.emp := it.next
		END;
		IF it.next # NIL THEN
			it.next.prev := it.prev
		END;
		it.next := NIL; it.prev := NIL;
		IF p.freeN < p.par.size THEN
			it.next := p.free;
			IF p.free # NIL THEN p.free.prev := it END;
			p.free := it;
			INC(p.freeN)
		ELSE
			Lf.hm.Recycle(it.db);
			it.next := items;
			items := it
		END;
		DEC(p.empN)
	END ReturnToPool;

	PROCEDURE (p: Pool) Collect*, NEW;
		VAR it, next: PoolItem;
			db: Database;
	BEGIN
		IF (p.lastCollect + p.par.collectPeriod < Lf.TimeMs())
			OR (p.freeN = 0) & (p.lastCollect + p.par.collectPeriodIfNoFree < Lf.TimeMs()) THEN
			it := p.emp;
			WHILE it # NIL DO
				next := it.next;
				IF Lf.TimeMs() > it.t THEN
					db := it.db;
					db.ReturnToPool
				END;
				it := next
			END;
			p.lastCollect := Lf.TimeMs()
		END
	END Collect;

	PROCEDURE (p: Pool) IsIdle* (): BOOLEAN, NEW;
	BEGIN
	RETURN p.emp = NIL
	END IsIdle;

	PROCEDURE (p: Pool) Close*, NEW;
		VAR it: PoolItem;
			closed: BOOLEAN;
	BEGIN
		it := p.emp;
		WHILE it # NIL DO
			it.db.Rollback;
			it.db.Close(closed);
			it := it.next
		END;
		it := p.free;
		WHILE it # NIL DO
			it.db.Rollback;
			it.db.Close(closed);
			it := it.next
		END
	END Close; */