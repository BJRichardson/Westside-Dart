import '../westside_backend.dart';

class GroupEvent extends ManagedObject<_GroupEvent> implements _GroupEvent {

  @override
  bool operator ==(other) {
    return id == other.id;
  }
}

class _GroupEvent {
  @managedPrimaryKey
  int id;

  @ManagedRelationship(#groupEvents, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Group group;

  @ManagedRelationship(#groupEvents, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Event event;

}