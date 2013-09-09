class WiPPawnReplicationInfo extends WiPPlayerReplicationInfo;

// Attack speed multiplier for this unit
var float AttackSpeed;
// Link to the player replication info that owns this pawn
var PlayerReplicationInfo PlayerReplicationInfo;

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	// Never broadcast welcome message
	return false;
}

replication{
    if (bNetDirty)
        AttackSpeed, PlayerReplicationInfo;
}

defaultproperties
{}