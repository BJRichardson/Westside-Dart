import '../westside_backend.dart';

class UserAnnouncement extends ManagedObject<_UserAnnouncement> implements _UserAnnouncement {

}

class _UserAnnouncement {
  @managedPrimaryKey
  int id;

  @ManagedRelationship(#announcements, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  User user;

  @ManagedRelationship(#userAnnouncements, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Announcement announcement;
}