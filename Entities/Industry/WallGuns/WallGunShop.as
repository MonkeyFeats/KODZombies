// BuilderShop.as

#include "Requirements.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "Guns.as";
#include "SoldierCommon.as";
#include "PopupTextButton.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("buy");

	AddIconToken("$trade$", "Coins.png", Vec2f(16, 16), 1);	

	PopupTextButton button = PopupTextButton(this, this.getName(), "Buy \n 3000", this.getPosition(), color_white, this.getCommandID("buy") );
	this.set("buttonInfo", @button);
}

//void GetButtonsFor(CBlob@ this, CBlob@ caller)
//{
//	SoldierInfo@ soldier; if (!caller.get("SoldierInfo", @soldier)) { return; }
//	GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }
//
//	if ((caller.getPosition().x - this.getPosition().x) <= 12.0f && (caller.getPosition().y - this.getPosition().y) <= 12.0f)
//	{	
//		CBitStream params;
//		params.write_u16(caller.getNetworkID());
//		CButton@ button = caller.CreateGenericButton("$trade$", Vec2f_zero, this, this.getCommandID("buy"), getTranslatedString("Buy \n 3000"), params);
//
//		button.radius = 12.0f;
//		button.enableRadius = 14.0f;
//	}
//}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("buy"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());

		u16 GunType = this.getSprite().getFrameIndex();

		SoldierInfo@ soldier; if (!blob.get("SoldierInfo", @soldier)) { return; }

		switch (GunType)
		{
			case 0: 
		}

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