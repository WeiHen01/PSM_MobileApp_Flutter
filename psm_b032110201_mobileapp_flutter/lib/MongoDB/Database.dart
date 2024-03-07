import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'MongoURL.dart';

class MongoDatabase{
  
  static var db, collection;

  Db? database;

  Future<Db> open(String collectionName) async {
    try {
      db = await Db.create(MONGODB_URL);
      await db!.open();
      db!.collection(collectionName);
      debugPrint('MongoDB Connected');
      return db!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> close() {
    try {
      db!.close();
      debugPrint('MongoDB Closed');
    } catch (e) {
      debugPrint(e.toString());
    }
    return Future.value();
  }

  Future<void> insertItem(String collectionName, Map<String, dynamic> document) async {
    try {
      await open(collectionName);
      await db!.collection(collectionName).insert(document);
      debugPrint('Document Inserted');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> removeItem(ObjectId id, String collectionName) async {
    try {
      await open(collectionName);
      await db!.collection(collectionName).remove(where.id(id));
      debugPrint('Document Removed');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateItem(ObjectId id, String collectionName, document) async {
    try {
      await open(collectionName);
      await db!.collection(collectionName).update(where.id(id), document);
      debugPrint('Document Updated');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List> getList(String collectionName) async {
    try {
      await open(collectionName);
      var userList = await db!.collection(collectionName).find().toList();
      debugPrint('Document Fetched');
      return userList;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

 
}