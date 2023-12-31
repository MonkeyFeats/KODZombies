
void onInit(CSprite@ this)
{
	//CSpriteLayer@ jugsign = this.addSpriteLayer("jugsign", "PerkMachine.png", 16, 16, this.getBlob().getTeamNum(), 0);
	//if (jugsign !is null)
	//{		
	//	jugsign.addAnimation("default", 0, false);
	//	int[] frames = {2};
	//	jugsign.animation.AddFrames(frames);		
	//	jugsign.SetOffset(Vec2f(0, -10));
	//	jugsign.SetVisible(true);
	//}
}

void onInit(CBlob@ this)
{
	this.Tag("respawn");
}