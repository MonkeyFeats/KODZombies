// Builder animations

#include "FireCommon.as";
#include "Requirements.as";
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "SoldierCommon.as";
#include "Knocked.as";
#include "PixelOffsets.as";
#include "RunnerTextures.as";

//
Vec2f MainArmOffset = Vec2f(3.0f, -4.0f);
Vec2f SubArmOffset = Vec2f(-3.0f, -4.0f);
Vec2f KnifeOffset = Vec2f(-12.0f, -4.0f);

void onInit(CSprite@ this)
{
	RunnerTextures@ runner_tex = addRunnerTextures(this, "soldier", "HumanBod");
	LoadSprites(this);
}

void onPlayerInfoChanged(CSprite@ this)
{
	LoadSprites(this);
}

void LoadSprites(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "soldier", "HumanBod");

	string texname = getRunnerTextureName(this);

	this.RemoveSpriteLayer("legs");
	CSpriteLayer@ legs = this.addSpriteLayer("legs", "HumanLegs.png" , 16, 16, this.getBlob().getTeamNum(), 0);

	if (legs !is null)
	{
		Animation@ anim = legs.addAnimation("default", 0, false);
		anim.AddFrame(0);
		
		Animation@ run = legs.addAnimation("run", 3, true);
		run.AddFrame(0);
		run.AddFrame(1);
		run.AddFrame(2);
		run.AddFrame(3);

		legs.SetOffset(Vec2f(0.0f, 2.0f));
		legs.SetAnimation("default");
		legs.SetVisible(true);
	}

	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", "FrontArms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		frontarm.SetOffset(MainArmOffset);
		frontarm.SetRelativeZ(3.0f);
		frontarm.SetVisible(true);
	}

	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", "FrontArms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		int[] frames = {0, 1, 2, 3};
		anim.AddFrames(frames);
		backarm.SetOffset(SubArmOffset);
		backarm.SetRelativeZ(-3.0f);
		backarm.SetVisible(true);
	}	

	this.RemoveSpriteLayer("gun");
	CSpriteLayer@ gun = this.addSpriteLayer("gun", "Weapons.png" , 32, 16, 0, 0);
	if (gun !is null)
	{
		Animation@ anim = gun.addAnimation("default", 0, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
		anim.AddFrames(frames);
		gun.SetOffset(MainArmOffset+Vec2f(-7,1));
		gun.SetRelativeZ(2.0f);
		gun.SetVisible(true);
		gun.ScaleBy(Vec2f(0.75f, 0.75f));
	}	
}

void setAimValues(CSpriteLayer@ arm, bool visible, f32 angle, Vec2f around)
{
	if (arm !is null)
	{
		arm.ResetTransform();
		arm.RotateBy(angle, around);
	}
}

f32 getAimAngle(CBlob@ this) 
{
 	Vec2f blobPos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	Vec2f aimDir = blobPos-aimPos;

    return -aimDir.Angle();
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	SoldierInfo@ soldier;
	if (!blob.get("SoldierInfo", @soldier)) { return; }

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool running = (left || right);

	CSpriteLayer@ legs = this.getSpriteLayer("legs");
	CSpriteLayer@ frontarm = this.getSpriteLayer("frontarm");
	CSpriteLayer@ backarm = this.getSpriteLayer("backarm");

	CSpriteLayer@ gunlayer = blob.getSprite().getSpriteLayer("gun"); //doesn't need to be set every frame
	if (gunlayer !is null)	
	{
		gunlayer.SetFrameIndex(soldier.Guns[soldier.currentGunSlot].SPRITE_FRAME);
	}

	int swingdir = blob.get_s8("armswing direction");
	int armswing = blob.get_s16("armswing_counter");

	int inverse = 1;
	if(this.isFacingLeft())inverse = -1;
	
	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	Vec2f vec = aimpos - pos;
	f32 angle = -vec.Angle();	
	
	if (this.isFacingLeft()) { angle = 180.0f + angle; 	}
	while (angle > 180.0f)   { angle -= 360.0f; 		}
	while (angle < -180.0f)  { angle += 360.0f; 		}
	
	if (!blob.hasTag(burning_tag) && !blob.hasTag("dead"))
	{
		//const bool left = blob.isKeyPressed(key_left);
		//const bool right = blob.isKeyPressed(key_right);
		//const bool running = (left || right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		Vec2f pos = blob.getPosition();

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}		

		if (running)
		{
			legs.SetAnimation("run");
			if(armswing >= 9)	blob.set_s8("armswing direction", -1);
			if(armswing <= 0)	blob.set_s8("armswing direction", 1);
			blob.set_s16("armswing_counter",armswing+swingdir);
		}
		else
		{
			legs.SetAnimation("default");
		}

//		if ((left || right) ||
//		         (blob.isOnLadder() && (up || down)))
//		{
//			this.getSpriteLayer("frontleg").SetAnimation("run");
//			this.getSpriteLayer("backleg").SetAnimation("run");
//		}
//		else
//		{
//			// get the angle of aiming with mouse
//			Vec2f aimpos = blob.getAimPos();
//			Vec2f vec = aimpos - pos;
//			f32 angle = vec.Angle();
//			int direction;
//
//			if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
//			        (angle > 150 && angle < 210))
//			{
//				direction = 0;
//			}
//			else if (aimpos.y < pos.y)
//			{
//				direction = -1;
//			}
//			else
//			{
//				direction = 1;
//			}
//
//			this.getSpriteLayer("frontleg").SetAnimation("default");
//			this.getSpriteLayer("backleg").SetAnimation("default");
//		}
	}	
	//looky looky
	setAimValues(this.getSpriteLayer("head"), false, Maths::Min(60,Maths::Max(-30,angle)), Vec2f(0, 4) );

	if (soldier.state == SoldierParams::knifing)
	{
		backarm.SetFrameIndex(2);		
		setAimValues(backarm, true, angle, Vec2f_zero );
		this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f((Maths::Sin(1+soldier.action_timer/4.0f )*5.0f)+3,0).RotateBy(-angle*inverse));

		//setAimValues(this.getSpriteLayer("knife"), true, soldier.knife_angle, Vec2f(9*inverse, 0));
		//this.getSpriteLayer("knife").SetOffset(SubArmOffset+Vec2f((soldier.action_timer/4),0).RotateBy(-soldier.knife_angle*inverse));
		//this.getSpriteLayer("knife").SetVisible(true);

		setAimValues(frontarm, false, 60*inverse, Vec2f(-1*inverse, 0) );
		setAimValues(this.getSpriteLayer("gun"), false, 60*inverse, Vec2f(4*inverse, 0) );
				
	}	
	else if (running) // with something big
	{
		//setAimValues(this.getSpriteLayer("frontarm"), true, -15*inverse+angle+armswing*inverse*2, Vec2f(4*inverse, -2) );
		setAimValues(this.getSpriteLayer("backarm"), true, (25*inverse)+(armswing*3*inverse), Vec2f_zero );
		backarm.SetFrameIndex(0);

		setAimValues(this.getSpriteLayer("gun"), false, angle, Vec2f(4*inverse, 0)  );
		backarm.SetOffset(SubArmOffset);
	}
	else
	{
		setAimValues(this.getSpriteLayer("backarm"), true, 25*inverse, Vec2f_zero );
		backarm.SetFrameIndex(0);

		setAimValues(this.getSpriteLayer("frontarm"), false, angle*0.75, Vec2f(-1*inverse, 0) );
		setAimValues(this.getSpriteLayer("gun"), false, angle, Vec2f(4*inverse, 0)  );
		backarm.SetOffset(SubArmOffset);
	}	
	
	//setAimValues(this.getSpriteLayer("backarm"), false, angle*0.9, Vec2f(1*inverse, 1) );		

	// set egg type
	if (action1)
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (blob.isInFlames())
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else 
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}

}

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

// render cursors
/*
const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

//	CBlob@ blob = this.getBlob();
//	Vec2f pos = blob.getPosition();
//	Vec2f vel = blob.getVelocity();
//	vel.y -= 3.0f;
//	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
//	const u8 team = blob.getTeamNum();
//	CParticle@ Body     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
//	CParticle@ Arm1     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
//	CParticle@ Arm2     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
//	CParticle@ Shield   = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
//	CParticle@ Sword    = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
