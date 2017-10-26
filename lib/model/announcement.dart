import '../westside_backend.dart';

class Announcement extends ManagedObject<_Announcement> implements _Announcement {

  @managedTransientInputAttribute
  int posterId;

  @managedTransientOutputAttribute
  Map poster;

  Map<String, dynamic> asMap() {
    var map = super.asMap();
    map.remove("userAnnouncements");
    return map;
  }
}

class _Announcement {
  @managedPrimaryKey
  int id;

  DateTime createdDate;
  String announcement;

  @ManagedColumnAttributes(nullable: true)
  DateTime updatedDate;

  @ManagedColumnAttributes(nullable: true)
  String imageUrl;

  @ManagedColumnAttributes(nullable: true)
  int groupId;

  ManagedSet<UserAnnouncement> userAnnouncements;

}