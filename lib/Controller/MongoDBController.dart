/**
 * This class is a wrapper class for enabling Flutter to MongoDB
 */


import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../MongoDB/MongoURL.dart';

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
      await db!.collection(collectionName).insert(document);
      debugPrint('Document Inserted');
      //db!.close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Map<String, dynamic>> insert(String collectionName, final document) async {

    try {
      await db!.collection(collectionName).insert(document);
      debugPrint('Document Inserted');
      // Return the inserted document
       return document;
    } catch (e) {
      debugPrint(e.toString());
       throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }

  Future<void> removeItem(ObjectId id, String collectionName) async {
    try {
      await db!.collection(collectionName).remove(where.id(id));
      debugPrint('Document Removed');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /**
   * Remove by attributes
   */
  Future<void> delete(int id, String collectionName, String attributes) async {
    try {
      if (db == null || !db.isConnected) {
        await open(collectionName);
      } 
      await db!.collection(collectionName).remove(where.eq(attributes, id));
      debugPrint('Document Removed');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateItem(ObjectId id, String collectionName, document) async {
    try {
      await db!.collection(collectionName).update(where.id(id), document);
      debugPrint('Document Updated');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /**
   * Update by attributes
   * 
   * attribute here -> Attribute name in MongoDB
   */
  Future<bool> update_1(String collection, String attribute, var value, requestBody) async {
    try {
      // Update the document with the specified ID using the request body
      await db!.collection(collection).update(where.eq(attribute, value), requestBody);
      debugPrint('Document Updated');
      
      // Retrieve the updated document
      var updatedDocument = await db!.collection(collection).findOne(where.eq(attribute, value));

      // Print the updated document
      print('Updated document: $updatedDocument');

      return true;

    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> update(String collection, String attribute, var value, requestBody) async {
    try {
      //await open(collection);
      var collection_get = db.collection(collection);

      var selector = where.eq(attribute, value); // Specify the document to update based on DoctorID

      var update = ModifierBuilder();
      // Update each field specified in the requestBody
      requestBody.forEach((key, value) {
        update.set(key, value);
      });

      await collection_get.update(selector, update);

      // Retrieve the updated document
      var updatedDocument = await db!.collection(collection).findOne(where.eq(attribute, value));

      // Print the updated document
      print('Updated document: $updatedDocument');

      return true;

    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


  Future<bool> updateLastLoginDateTime(String collection, String attribute, var value, DateTime lastLoginDateTime) async {
    try {
      //await open(collection);
      
      // Find the doctor by email
      var result = await db!.collection(collection).findOne(where.eq(attribute, value));
      if (result != null) {
        // Update LastLoginDateTime field
        result["LastLoginDateTime"] = lastLoginDateTime.toLocal();
        await db!.collection(collection).update(where.eq(attribute, value), result);
        debugPrint('Last Login Date Time Updated');
        return true;
      } else {
        debugPrint('This account not found');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateLastUpdateDateTime(String collection, String attribute, var value, DateTime lastLoginDateTime) async {
    try {
      //await open(collection);
      
      // Find the doctor by email
      var result = await db!.collection(collection).findOne(where.eq(attribute, value));
      if (result != null) {
        // Update LastLoginDateTime field
        result["LastUpdateDateTime"] = lastLoginDateTime.toLocal();
        await db!.collection(collection).update(where.eq(attribute, value), result);
        debugPrint('Last Update Date Time Updated');
        return true;
      } else {
        debugPrint('This account not found');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List> getCertainInfo(String collectionName) async {
    try {
      if (db == null) {
        await open(collectionName);
      } else {
        this.database = db;
      }
      var userList = await db!.collection(collectionName).find().toList();
      debugPrint('Document Fetched');
      return userList;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List> getByQuery(String collectionName, Map<String, dynamic> query) async{
    try{
      if (db == null) {
        await open(collectionName);
      } else {
        this.database = db;
      }
      var lists = await db!.collection(collectionName).find(query).toList();
      return lists;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    
  }


  // Other methods...

  Future<List<Map<String, dynamic>>> getByQuery2(String collectionName, Map<String, dynamic> query, Map<String, dynamic> sortOrder) async {
    try {
      if (db == null) {
        await open(collectionName);
      } else {
        this.database = db;
      }
      var lists = await db!.collection(collectionName).find(query).sort(sortOrder).toList();
      return lists;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getByQuery3(String collectionName, Map<String, dynamic> query) async {
    try {
      if (db == null) {
        await open(collectionName);
      } else {
        this.database = db;
      }
      var lists = await db!.collection(collectionName).find(query).toList();
      return lists;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
 
}