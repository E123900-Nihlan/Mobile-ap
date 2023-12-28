import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Contact {
  int? id;
  String name;
  String contact;

  Contact({this.id, required this.name, required this.contact});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'contact': contact};
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT
      )
    ''');
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getContacts() async {
    Database db = await database;
    List<Map<String, dynamic>> contactMaps = await db.query('contacts');
    return contactMaps
        .map((map) =>
            Contact(id: map['id'], name: map['name'], contact: map['contact']))
        .toList();
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    return await db.update('contacts', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Contact>> searchContacts(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> contactMaps = await db.query(
      'contacts',
      where: 'name LIKE ? OR contact LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return contactMaps
        .map((map) =>
            Contact(id: map['id'], name: map['name'], contact: map['contact']))
        .toList();
  }
}
