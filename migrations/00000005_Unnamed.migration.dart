import 'package:aqueduct/aqueduct.dart';   
import 'dart:async';

class Migration5 extends Migration { 
  @override
  Future upgrade() async {
   database.createTable(new SchemaTable("_UserEvent", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn("isAttending", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
new SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
new SchemaColumn.relationship("event", ManagedPropertyType.bigInteger, relatedTableName: "_Event", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.createTable(new SchemaTable("_GroupEvent", [
new SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
new SchemaColumn.relationship("group", ManagedPropertyType.bigInteger, relatedTableName: "_Group", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
new SchemaColumn.relationship("event", ManagedPropertyType.bigInteger, relatedTableName: "_Event", relatedColumnName: "id", rule: ManagedRelationshipDeleteRule.cascade, isNullable: false, isUnique: false),
],
));


  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    