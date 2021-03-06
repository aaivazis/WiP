class WiPChampion extends WiPPawn
    implements (WiPAttackable);

// the default melee weapon archetype
var(Weapon) const archetype WiPChampion_MeleeWeapon DefaultMeleeWeaponArchetype;
// the default melee weapon archetype
var(Weapon) const archetype WiPChampion_RangedWeapon DefaultRangedWeaponArchetype;

// an array of this champions abilities
var(Champion) array<WiPAbility>  Abilities;

// the base mana regen rate
var(Stats) const float BaseManaRegen;
// the base maximum mana amount
var(Stats) const float BaseMaxMana;
// How much mana the hero has
var repnotify float Mana;

// the spell currently activated by the champion
var repnotify WiPAbility activatedAbility;


var repnotify int test;

replication
{
    if (bNetDirty || bNetOwner)
       Mana, ActivatedAbility, test;
}



simulated event PostBeginPlay(){

   local int i;

    super.PostBeginPlay();

    // Only the server needs to spawn the AIController which is used for pathing
	if (Role == Role_Authority)
	{
		SpawnDefaultController();


	}
	
	// replace abilities with instantiated version of their archetype
    	for (i=0; i< Abilities.Length ; i++){
            Abilities[i] = Spawn(Abilities[i].class,,,Location, ,Abilities[i]);
        }


	currentHealth = BaseHealth;
	mana = BaseMaxMana;
}




// recalcuate the pawn's stats
function recalculateStats(){

    local WiPChampionReplicationInfo champRepInfo;
	local bool JustSpawned;

    if (Role != Role_Authority) return;

    Super.recalculateStats();


    champRepInfo = WiPChampionReplicationInfo(PlayerReplicationInfo);

    if (champRepInfo != none){
       champRepInfo.ManaRegen = StatModifier.CalculateStat(STAT_ManaRegen, BaseManaRegen);
       champRepInfo.MaxMana = StatModifier.CalculateStat(STAT_MaxMana, BaseMaxMana);
    }

    JustSpawned = (Abs(WorldInfo.TimeSeconds - SpawnTime) < 0.05f);
   	
    // If just spawned, then set Health to HealthMax
	// and mana to maxMana

    if (JustSpawned){
        if (champRepInfo != none){
           `log("just spawned and I found a champ rep ... setting mana " @ StatModifier.CalculateStat(STAT_MaxMana, BaseMaxMana));
             mana = StatModifier.CalculateStat(STAT_MaxMana, BaseMaxMana);
        }
    }
}

// called everytime the champion updates (update mana)
simulated function Tick(float TimeDelta){

    local WiPChampionReplicationInfo champRepInfo;

    if (Role != Role_Authority) return;

    Super.Tick(TimeDelta);

    champRepInfo = WiPChampionReplicationInfo(PlayerReplicationInfo);
    if (champRepInfo == none ) return;

    Mana = FMin(champRepInfo.MaxMana, Mana + ( champRepInfo.ManaRegen * TimeDelta));

}

// called when the pawn dies (assign a new respawn time)
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation){
    local WiPChampionReplicationInfo champRepInfo;
    local WiPPlayerReplicationInfo playerRepInfo;


    // get replication information
    champRepInfo = WiPChampionReplicationinfo(PlayerReplicationInfo);
    if (champRepInfo != none) {

        playerRepInfo = WiPPlayerReplicationInfo(champRepInfo.PlayerReplicationInfo);
        if (playerRepInfo != none){

            playerRepInfo.NextRespawnTime = WorldInfo.TimeSeconds + 15.f + (champRepInfo.Level * 5.f);
            `log("player respawn time ============ " @ playerRepInfo.NextRespawnTime );
        }
    }

    return Super.Died(Killer, DamageType, HitLocation);

}

// add the default weapon
function AddDefaultInventory(){

    local WiPInventoryManager wipInvManager;

    // add the default weapon for the champion to handle white damage
    wipInvManager = WiPInventoryManager(InvManager);
    if (wipInvManager != none){
        //wipInvManager.CreateInventoryByArchetype(defaultMeleeWeaponArchetype, false);
        wipInvManager.CreateInventoryByArchetype(defaultRangedWeaponArchetype, false);

    }
}

// return attacking rate
function float getAttackingRate(){
    return 0.1f;
}


simulated function float AbilityTargetCenterFromRot(){

    local vector	POVLoc;
	local rotator	POVRot;
    local float fracAngle, maxRange;

    if (ActivatedAbility == none) return 0;

    //maxRange = ActivatedAbility.GetRange();
    maxRange = 200;

	if( Controller != None)
	{
		Controller.GetPlayerViewPoint(POVLoc, POVRot);
	}

    fracAngle = POVRot.Pitch/65536.f;

    // if we are aiming in the first quadrant, return max range
    if (fracAngle > 0 && fracAngle < 0.25f)
       return maxRange;

    // if we are aiming in the 4th quadrant, return the correct range
    if (fracAngle > 0.75 && fracAngle < 1){
       return 100;
    }

    return 0;

}

simulated function SelectAbility(byte slot){
    if (Role < Role_Authority){
        ServerSelectAbility(slot);
    }

    ActivateAbility(slot);
}

reliable server function ServerSelectAbility(byte slot){
    ActivateAbility(slot);
}

simulated function ActivateAbility(byte slot){
    activatedAbility = Abilities[slot];

    `log("Tried to activate " @ slot);
    `log("current mana " @ Mana );

    test++;

    if (activatedAbility.CanActivate() && mana >= activatedAbility.GetManaCost()){
       `log("Activated Spell at Slot " @ slot);
       GoToState('ActiveAbility');
    }
}



// return the team number of this pawn
simulated function byte GetTeamNum(){

    return 0;
}



/*****************************************************************
*   Interface - WiPAttackble                                     *
******************************************************************/

// return the actor implimenting this interface
simulated function Actor getActor(){
    return self;
}

// return the amount of white damage (auto attacks)
simulated function int getWhiteDamage(){
    return BaseAttackDamage;
}

// return the actors attacking priority - lower than creeps
simulated function int getAttackPriority(Actor Attacker){
    return 5;
}

// return the damage type for white damage
simulated function class<DamageType> GetDamageType(){
    return PawnDamageType;
}

// need to impliment
simulated function GetWeaponFiringLocationAndRotation(out Vector FireLocation, out Rotator FireRotation){

    local vector newLoc;
    
    newLoc = Location;
    newLoc.Z = 10;

    FireLocation = newLoc;
	FireRotation = Rotation;
}

/*****************************************************************
*   State - Active Ability                                       *
******************************************************************/

state ActiveAbility{

    // called when the state is first entered
    function BeginState(Name PreviousStateName){
        
        `log("server is in the right state");

        `log("Activated an ability = " @ activatedAbility );

        if (activatedAbility == none) GoToState();



    }

    // overwrite so that click casts the weapon
    simulated function StartFire(byte FireModeNum){

        if ( Role < ROLE_Authority){
           ServerStartFire(FireModeNum);
        }

        BeginCast();

    }
}

reliable server function ServerStartFire(byte FireModeNum){
    test++;
        BeginCast();
}

simulated function BeginCast(){
       local vector target;

       target.X = AbilityTargetCenterFromRot();

       target = (target >> Rotation) + Location;

        `log("Casted an ability " @ activatedAbility);

        if (activatedAbility == none) GoToState('');
        
        if (Mana < activatedAbility.GetManaCost()){
           `log("not enough mana to use that ability");
            GoToState('');
        }

        Mana -= activatedAbility.GetManaCost();

        ActivatedAbility.Cast(self, target);

        GoToState('');
}





defaultProperties
{

	RewardRange = 2000.f
    BaseHealth = 150.f
    BaseAttackDamage = 50
	BaseAttackSpeed=1.f
	PawnDamageType = class'DamageType'
    ControllerClass = class'WiPChampionController'
    ExperienceToGiveOnKill = 200
    MoneyToGiveOnKill = 400
    LastHitMultiplier = 1.2
    HealthMax = 100
    BaseHealthRegen = 1
    BaseMaxHealth = 150
    BaseMaxMana = 200
    BaseManaRegen = .3
    
    test = 0

    DefaultMeleeWeaponArchetype = WiPChampion_MeleeWeapon'WiP_ASSETS.Archetypes.DefaultChampionMeleeWeapon'
    DefaultRangedWeaponArchetype = WiPChampion_RangedWeapon'WiP_ASSETS.Archetypes.DefaultChampionRangedWeapon'
}