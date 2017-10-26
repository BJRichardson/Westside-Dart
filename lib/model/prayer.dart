import '../westside_backend.dart';

class Prayer extends ManagedObject<_Prayer> implements _Prayer {

  @managedTransientInputAttribute
  int posterId;

  @managedTransientOutputAttribute
  Map poster;

  Map<String, dynamic> asMap() {
    var map = super.asMap();
    map.remove("userPrayers");
    return map;
  }
}

class _Prayer {
  @managedPrimaryKey
  int id;

  DateTime createdDate;
  String prayer;

  @ManagedColumnAttributes(nullable: true)
  DateTime updatedDate;

  ManagedSet<UserPrayer> userPrayers;

}