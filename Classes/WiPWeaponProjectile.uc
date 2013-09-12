class WiPWeaponProjectile extends UDKProjectile;

// the damage of damage done by the projectile
var const int Damage;
// wether this projectile passes through enemies 
var const bool PassThrough;


// Called every time the projectile hits an actor
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal){
    local WiPAttackable target;

    // only handle actors that are WiPAttackable
    target = WiPAttackable(Other);
    if (target == none) return;
    
    // only deal damage if it is okay to do so
    if (!target.isValidToAttack()) return;

	if (DamageRadius > 0.0){
		Explode( HitLocation, HitNormal );

    }else{

		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
        if(! passThrough){
            destroy();
        }
	}
}


/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{
	SetRotation(rotator(Direction));
    
    //
	Velocity = Speed * Direction;
	Velocity.Z = 0;
	Acceleration = AccelRate * Normal(Velocity);
}

DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)
 
    begin object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'WP_BioRifle.Mesh.S_Bio_Blob_01'
        LightEnvironment=MyLightEnvironment
    end object

    Components.Add(BaseMesh)
    
    Damage = 20
    DamageRadius =0
}