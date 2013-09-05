class WiPPawn extends GamePawn;

var name WeaponSocket;

simulated event ReplicatedEvent(name VarName)
{
	// Money was replicated
	`Log("ReplicatedEvent:"@VarName);
	Super.ReplicatedEvent(VarName);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("Custom Pawn up");
}

simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	`Log("Requested Isometric");
	`Log("Role"@Role);
    return 'Isometric';
}

function AddDefaultInventory()
{
	//InvManager.CreateInventory(class'Weapon_Sniper'); //InvManager is the pawn's InventoryManager
	InvManager.CreateInventory(class'UTWeap_LinkGun'); //InvManager is the pawn's InventoryManager

	`Log("Default Inventory created!");
}

//fix aiming to a plane
simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;


   `Log("GetBaseAimRotation"@Rotation);
   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   `Log("GetBaseAimRotation"@Rotation);
   `Log("tempRot"@tempRot);
   `Log("POVRot"@POVRot);

   return POVRot;
}


//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         UTPawn(PC.Pawn).SetMeshVisibility(UTPC.bBehindView);
         UTPC.bNoCrosshair = true;
      }
   }
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	InventoryManagerClass=class'WiPInventoryManager';
	WeaponSocket=WeaponPoint;

	// Collision
	BaseEyeHeight=+00008.000000
	EyeHeight=+00008.000000
	
}
