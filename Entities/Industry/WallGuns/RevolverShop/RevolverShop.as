// BuilderShop.as

#include "Requirements.as"
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("buy");

	AddIconToken("$trade$", "Coins.png", Vec2f(16, 16), 1);

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change

	if ((caller.getPosition().x - this.getPosition().x) <= 12.0f && (caller.getPosition().y - this.getPosition().y) <= 12.0f)
	{	
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$trade$", Vec2f_zero, this, this.getCommandID("buy"), getTranslatedString("Buy \n 3000"), params);

		button.radius = 12.0f;
		button.enableRadius = 14.0f;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("buy"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());

		blob.set_u8("Slot0Type", 2);
		
	}
}