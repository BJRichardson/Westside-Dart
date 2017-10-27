import 'package:aqueduct/aqueduct.dart';   
import 'dart:async';

class Migration8 extends Migration { 
  @override
  Future upgrade() async {
   database.addColumn("_User", new SchemaColumn("firstName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));

database.addColumn("_User", new SchemaColumn("lastName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));

database.deleteColumn("_User", "name");


  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    