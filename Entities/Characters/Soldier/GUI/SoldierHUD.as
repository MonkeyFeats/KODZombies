//#define CLIENT_ONLY

#include "SoldierCommon.as"
#include "Guns.as"
#include "CoinFeed.as"
#include "InteractionMessages.as"

const f32 HUD_X = getScreenWidth()/2;
const f32 HUD_Y = getScreenHeight();
const u8 SlotSizeX = 80;
const u8 SlotSizeY = 40;

const string iconsFilename = "SoldierGui.png";
const int slotsSize = 6;

u16 coinslastframe;

void onInit(CBlob@ this)
{
	AddIconToken("$COIN$", "Sprites/coins.png", Vec2f(16, 16), 1);
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	CoinFeed feed;
	this.set("CoinFeed", feed);

	//InteractionMessages imessages;
	//this.set("InteractionMessages", imessages);
}

void onTick(CBlob@ this)
{
	SoldierInfo@ soldier; if (!this.get("SoldierInfo", @soldier)) { return; }
	GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }

	Vec2f TopLeft(HUD_X-(soldier.Guns.size()*SlotSizeX/2)-6, HUD_Y- SlotSizeY -6);

    CPlayer@ player = this.getPlayer();
    if (player is null) {return;}

	CoinFeed@ feed;
	if (this.get("CoinFeed", @feed) && feed !is null)
	{	
		u16 AmountChange = player.getCoins() - coinslastframe; //TODO: find a better way

		if (AmountChange > 0)
		{
			CoinMessage message("+"+AmountChange,  TopLeft + Vec2f(SlotSizeX+22 , 20));
			feed.coinMessages.push_back(message);
		}
		else if (AmountChange < 0)
		{
			CoinMessage message("-"+AmountChange,  TopLeft + Vec2f(SlotSizeX+22 , 20));
			feed.coinMessages.push_back(message);
		}

		coinslastframe = player.getCoins();
		feed.Update();
	}

	//InteractionMessages@ imessages;
	//if (this.get("InteractionMessages", @imessages) && imessages !is null)
	//{	
	//	CBlob@[] overlapping;
	//	if (getMap().getBlobsInRadius(this.getPosition(), 8, @overlapping))
	//	{
	//		InteractionMessage@ bmessage;
	//		for (uint i = 0; i < overlapping.size(); i++)
	//		{
	//			CBlob@ b = overlapping[i];
	//			if (b !is null && b !is this)
	//			{
	//				if (b.get("InteractMsg", @bmessage))
	//				{
	//					if (imessages.messages.find(bmessage) == -1)
	//					{
	//						imessages.messages.push_back(bmessage);
	//					}
	//				}
	//			}
	//		}
	//	}
	//	imessages.Update(this.getPosition());
	//}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	GUI::SetFont("menu");

	CBlob@ blob = this.getBlob();	
	CPlayer@ player = blob.getPlayer();	

	SoldierInfo@ soldier; if (!blob.get("SoldierInfo", @soldier)) { return; }
	GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }

	Vec2f TopLeft(HUD_X-(soldier.Guns.size()*SlotSizeX/2)-6, HUD_Y- SlotSizeY -6);
	Vec2f BottomRight(HUD_X+(soldier.Guns.size()*SlotSizeX/2), HUD_Y );

	for (int i = 0; i < soldier.Guns.size(); i++)
	{
		Vec2f SlotTopLeft = TopLeft+Vec2f(i*SlotSizeX, 0);
		soldier.currentGunSlot == i ? GUI::DrawButtonPressed(SlotTopLeft, SlotTopLeft+Vec2f(SlotSizeX, SlotSizeY)) : 
									  GUI::DrawButton(SlotTopLeft, SlotTopLeft+Vec2f(SlotSizeX, SlotSizeY));

		GUI::DrawIcon("Weapons.png", soldier.Guns[i].SPRITE_FRAME, Vec2f(32,16), SlotTopLeft+Vec2f(4, 3), 1.0f); // gunslot	
	}

	Vec2f ammodim;
	string ammonums =  ""+ gun.CLIP_AMMO + " / " + gun.TOTAL_AMMO;
	GUI::GetTextDimensions(ammonums , ammodim);

	GUI::DrawIcon("Weapons.png", 41, Vec2f(16,16), Vec2f(HUD_X -ammodim.x, HUD_Y-SlotSizeY-ammodim.y)-Vec2f(12,18), 1.0f); // ammo icon
	GUI::DrawTextCentered( ammonums , Vec2f(HUD_X, HUD_Y-SlotSizeY-ammodim.y), color_white);  // ammo text		

	GUI::DrawIcon("Weapons.png", 40, Vec2f(16,16), Vec2f(BottomRight.x+(3),BottomRight.y+24.0f), 1.0f); // grenade
	GUI::DrawText(""+soldier.grenade_ammo, Vec2f(BottomRight.x+(3.5),BottomRight.y), color_white); // grenade text	

	// Draw Coins
	CoinFeed@ feed;
	if (this.getBlob().get("CoinFeed", @feed) && feed !is null)
	{
		const int coins = player !is null ? player.getCoins() : 0;

		GUI::DrawIconByName("$COIN$", TopLeft + Vec2f(SlotSizeX, 12));		
		GUI::DrawText("" + coins, TopLeft + Vec2f(SlotSizeX+22 , 20), color_white);

		feed.Render();
	}

	// Draw Interactions
	//InteractionMessages@ imessages;
	//if (this.getBlob().get("InteractionMessages", @imessages) && imessages !is null)
	//{
	//	imessages.Render();
	//}
}

