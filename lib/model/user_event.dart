import '../westside_backend.dart';

class UserEvent extends ManagedObject<_UserEvent> implements _UserEvent {

}

class _UserEvent {
  @managedPrimaryKey
  int id;

  @ManagedRelationship(#events, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  User user;

  @ManagedRelationship(#userEvents, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Event event;

  @ManagedColumnAttributes(nullable: true)
  bool isAttending;
}