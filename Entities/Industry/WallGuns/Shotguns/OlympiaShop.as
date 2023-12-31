// BuilderShop.as
#include "Guns.as"
#include "SoldierCommon.as"
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("buy");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	SoldierInfo@ soldier; if (!caller.get("SoldierInfo", @soldier)) { return; }
	GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }

	if (!canSeeButtons(this, caller)) return;
	if (!this.isOverlapping(caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton("$trade$", Vec2f(-2,-12), this, this.getCommandID("buy"), "Buy 3000", params);

	button.radius = 32.0f;
	button.enableRadius = 32.0f;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("buy"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if (blob !is null)
		{
			SoldierInfo@ soldier; if (!blob.get("SoldierInfo", @soldier)) { return; }

			Olympia olympia;
			if (soldier.Guns.size() == 1)
			{
				soldier.Guns.push_back(olympia);
				soldier.currentGunSlot = 1;
			}
			else
			{
				@soldier.Guns[soldier.currentGunSlot] == olympia;
			}
		}
	}
}