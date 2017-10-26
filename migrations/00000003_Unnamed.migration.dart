import 'package:aqueduct/aqueduct.dart';   
import 'dart:async';

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   database.addColumn("_User", new SchemaColumn("roles", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));



  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    