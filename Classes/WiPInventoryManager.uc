class WiPInventoryManager extends InventoryManager;

function Inventory CreateInventoryByArchetype(Inventory NewInventoryItemArchetype, optional bool bDoNotActivate)
{
    local Inventory Inv;

    if (NewInventoryItemArchetype != none){

        Inv = Spawn(NewInventoryItemArchetype.Class, Owner,,,, NewInventoryItemArchetype);

        if (Inv != none){
            if (!AddInventory(Inv, bDoNotActivate))
            {
                Inv.Destroy();
                Inv = none;
            }
        }
    }

    return Inv;
}

DefaultProperties
{
    PendingFire(0)=0
    PendingFire(1)=0
}
