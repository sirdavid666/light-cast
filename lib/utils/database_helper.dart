import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';
import '../models/scripture.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lightcast.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        verses TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE scriptures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        text TEXT NOT NULL
      )
    ''');

    // Seed default songs
    final defaultSongs = [
      Song(title: 'Amazing Grace', verses: [
        'Amazing grace, how sweet the sound,\nThat saved a wretch like me!',
        'I once was lost, but now am found,\nWas blind, but now I see.',
        "T'was grace that taught my heart to fear,\nAnd grace my fears relieved;",
        'How precious did that grace appear\nThe hour I first believed.',
      ]),
      Song(title: 'Holy Spirit Move', verses: [
        'Holy Spirit, move in this place',
        'Fill our hearts with Your grace',
        'We surrender, we worship You',
        'Holy Spirit, move anew',
      ]),
      Song(title: 'Ancient Of Days', verses: [
        'Blessing and honour, glory and power',
        'Be unto the Ancient of Days',
        'From every nation, all of creation',
        'Bow before the Ancient of Days',
      ]),
    ];

    for (final song in defaultSongs) {
      await db.insert('songs', song.toMap());
    }

    // Seed default scriptures
    final defaultScriptures = [
      Scripture(
        reference: 'John 3:16',
        text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      ),
      Scripture(
        reference: 'Psalm 91:1-2',
        text: 'Whoever dwells in the shelter of the Most High will rest in the shadow of the Almighty. I will say of the LORD, "He is my refuge and my fortress, my God, in whom I trust."',
      ),
      Scripture(
        reference: 'Isaiah 60:1',
        text: 'Arise, shine, for your light has come, and the glory of the LORD rises upon you.',
      ),
    ];

    for (final scripture in defaultScriptures) {
      await db.insert('scriptures', scripture.toMap());
    }
  }

  // Songs CRUD
  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final maps = await db.query('songs', orderBy: 'title ASC');
    return maps.map((m) => Song.fromMap(m)).toList();
  }

  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert('songs', song.toMap());
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update('songs', song.toMap(),
        where: 'id = ?', whereArgs: [song.id]);
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  // Scriptures CRUD
  Future<List<Scripture>> getAllScriptures() async {
    final db = await database;
    final maps = await db.query('scriptures', orderBy: 'reference ASC');
    return maps.map((m) => Scripture.fromMap(m)).toList();
  }

  Future<int> insertScripture(Scripture scripture) async {
    final db = await database;
    return await db.insert('scriptures', scripture.toMap());
  }

  Future<int> updateScripture(Scripture scripture) async {
    final db = await database;
    return await db.update('scriptures', scripture.toMap(),
        where: 'id = ?', whereArgs: [scripture.id]);
  }

  Future<int> deleteScripture(int id) async {
    final db = await database;
    return await db.delete('scriptures', where: 'id = ?', whereArgs: [id]);
  }
}
