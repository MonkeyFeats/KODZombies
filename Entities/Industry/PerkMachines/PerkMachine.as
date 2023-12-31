#include "TeamColour.as";
void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("jugsign");
	CSpriteLayer@ jugsign = this.addSpriteLayer("jugsign", "PerkMachine.png", 16, 16, this.getBlob().getTeamNum(), 0);
	if (jugsign !is null)
	{		
		Animation@ anim = jugsign.addAnimation("default", 0, false);
		anim.AddFrame(2); //normal
		anim.AddFrame(3); //water
		anim.AddFrame(6); //fire
		anim.AddFrame(7); //bomb
		jugsign.SetAnimation("default");

		jugsign.SetOffset(Vec2f(0, -13));
		jugsign.SetVisible(true);

	}		
}

void setFrame(CBlob@ this)
{
	u8 frame = this.get_u8("type");

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	CSpriteLayer@ signlayer = sprite.getSpriteLayer("jugsign");
	if (signlayer is null) return;

	signlayer.animation.frame = frame;
}

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;	

	this.addCommandID("buy");

	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(getTeamColor(this.getTeamNum()));

	AddIconToken("$rest$", "InteractionIcons.png", Vec2f(32, 32), 29);	
}

void onTick(CBlob@ this)
{
	if (getGameTime() == 30)
	{
		setFrame(this);
	}
}