import 'package:aqueduct/aqueduct.dart';   
import 'dart:async';

class Migration6 extends Migration { 
  @override
  Future upgrade() async {
   database.createTable(new SchemaTable("_UserGroup", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
new SchemaColumn.relationship("group", ManagedPropertyType.bigInteger, relatedTableName: "_Group", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.createTable(new SchemaTable("_Announcement", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("createdDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("announcement", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("updatedDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
new SchemaColumn("imageUrl", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
new SchemaColumn("groupId", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
],
));

database.createTable(new SchemaTable("_UserAnnouncement", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
new SchemaColumn.relationship("announcement", ManagedPropertyType.bigInteger, relatedTableName: "_Announcement", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.createTable(new SchemaTable("_Prayer", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("createdDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("prayer", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("updatedDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
],
));

database.createTable(new SchemaTable("_UserPrayer", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
new SchemaColumn.relationship("prayer", ManagedPropertyType.bigInteger, relatedTableName: "_Prayer", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.addColumn("_Group", new SchemaColumn("imageUrl", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));



  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    