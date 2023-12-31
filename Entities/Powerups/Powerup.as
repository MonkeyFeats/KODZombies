
const string[] powerupTags = { "Insta Kill",
                               "Max Ammo",
                               "Nuke",
                               "Double Points",
                               "Carpenter",
                               "Death Machine"
                             };

void onInit(CBlob@ this)
{
	if (!this.exists("powerup"))
	{
		int p = XORRandom(powerupTags.length);
		this.set_string("powerup", powerupTags[p]);
		Animation@ anim = this.getSprite().addAnimation("default", 0, false);
		anim.AddFrame(p);
	}

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(0xffffffff);

	this.getShape().SetStatic(true);

	// todo: anim handling if preset powerup
	//this.setVelocity(Vec2f_zero);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!getNet().isServer()) { return; }

	if (blob !is null && blob.hasTag("player") && !blob.hasTag("dead"))
	{
		string tag = this.get_string("powerup");
		getNet().server_SendMsg("" + blob.getInventoryName() + " picked up '" + tag + "'");
		blob.Tag(tag);
		blob.Sync(tag, true);

		this.getSprite().PlaySound(CFileMatcher(tag+".ogg").getFirst());
	}
}

void onDie(CBlob@ this)
{
	//this.getSprite().PlaySound(CFileMatcher("Heart.ogg").getFirst());
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}