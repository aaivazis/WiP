class WiPWeaponFireMode extends Object // fire mode for creeps and towers
    abstract
    EditInlineNew
    HideCategories(Object);

// weapon owner
var ProtectedWrite WiPAttackable weaponOwner;
// store if the weapon is firing
var RepNotify bool bIsFiring;


function Destroy(){
	// Stop firing
	StopFire();

	// Clear the weapon owner
	WeaponOwner = None;
}

function float getAttackingAngle(){
    return 0.9f;
}

// set owner of the weapon
function setOwner(WiPAttackable newOwner){

    // prevent newOwner == none
    if (newOwner == none) return;

    weaponOwner = newOwner;
}

// return true if the actor is firing a weapon
function bool IsFiring(){

    return bIsFiring;
}

// stop firing
function stopFire(){
	if (weaponOwner != None){
		weaponOwner.getActor().ClearTimer(NameOf(Fire), Self);
		bIsFiring = false;
	}
}

// begins firing the weapon
function Fire(){
    local vector targetLoc;
    local Rotator targetRot;
    local Actor currentEnemy;


 //   `log("called fire ==============");

    // check if there is a weaponOwner
    if (weaponOwner == none) return;

    // grab the current enemy
    currentEnemy = WiPNeutralPawn(WeaponOwner) != none ? WiPNeutralPawn(WeaponOwner).GetEnemy() : none;
    // if if failed becaues its not a neutralPawn, try a tower
    if (currentEnemy == none) {
        if (WiPTower(WeaponOwner) != none){
            currentEnemy = WiPTower(WeaponOwner).GetEnemy();
        }

    }

    if (currentEnemy == none){
        StopFire();
        return;
    } 

    weaponOwner.GetWeaponFiringLocationAndRotation(targetLoc, targetRot);

    BeginFire(targetLoc, Rotator(currentEnemy.Location - targetLoc), currentEnemy);


}

// tbi by subclasses to finish off the weapon
protected function BeginFire(vector fireLoc, Rotator fireRotation, Actor enemy);

// start the weapon loop
function startFire(){
    local float firingRate;
    local WiPNeutralPawn neutralPawn;
    local WiPPawnReplicationInfo pawnRepInfo;


  //  `log("Called StartFire!=====================");
  //  `log("Targeting =========================" @ WiPNeutralPawn(WeaponOwner).GetEnemy() );

    if (weaponOwner != none){
        fire();

        neutralPawn = WiPNeutralPawn(WeaponOwner);
        if (neutralPawn != none){

            pawnRepInfo = WiPPawnReplicationInfo(neutralPawn.PlayerReplicationInfo);
            
            firingRate = (pawnRepInfo != none && (pawnRepInfo.AttackSpeed > 1.f)) ? pawnRepInfo.AttackSpeed : neutralPawn.BaseAttackSpeed;

         //   `log("Final Firing rate ========================== " @ firingRate);

            // start firing timer
            WeaponOwner.GetActor().SetTimer(firingRate, true, NameOf(Fire), self);
            bIsFiring = true;

        // the owner exists but isn't a pawn, therefore its a tower
        } else {
            WeaponOwner.GetActor().SetTimer(1, true, NameOf(Fire), self);
            bIsFiring = true;


        }
    }
}

defaultproperties{}