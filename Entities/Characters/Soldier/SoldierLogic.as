
//#include "ThrowCommon.as";
#include "Hitters.as";
#include "Knocked.as";
#include "RunnerCommon.as";
#include "SoldierCommon.as";
#include "Bullet_Particles.as";

const string SHOOT_CMD = "shoot";
const string RELOAD_CMD = "reload";

int CursorFrame = 0;

void onInit(CBlob@ this)
{
	this.addCommandID(SHOOT_CMD);
    this.addCommandID(RELOAD_CMD);
    this.addCommandID("Knife");    
    this.addCommandID("ThrowNade");
    this.addCommandID("buy");

	this.Tag("player");
	this.Tag("flesh");
    this.set_f32("gib health", -3.0f);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;	

	SoldierInfo soldier;
	this.set("SoldierInfo", @soldier);

	getCamera().targetDistance = 2.0;
	getCamera().mouseFactor = 0.25f;

	soldier_actorlimit_setup(this);

	ColtPistol colt;
	soldier.Guns.push_back(colt);

	//GunInfo gun2; // none
	//this.set("Gun1Info", @gun2);
}

void onTick(CBlob@ this)
{	
	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer)	
    {
    	CControls@ controls = getControls(); if (controls is null) { return; }
		SoldierInfo@ soldier; if (!this.get("SoldierInfo", @soldier)) { return; }
		GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }		

		const f32 aimangle = getAimAngle(this);

		const bool Action1 = this.isKeyPressed(key_action1);
		const bool Action2 = this.isKeyPressed(key_action2);
		const bool Action3 = this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup);	
		const bool ActionReload = controls.isKeyJustPressed(KEY_KEY_R);
		const bool switchUp = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT));
		const bool switchDown = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN));
		const bool CookNade =  this.isKeyJustPressed(key_action3);
		const bool ThrowNade = this.isKeyJustReleased(key_action3);		

		if((ismyplayer && getHUD().hasMenus()) || getKnocked(this) > 0)
		{
			soldier.state = SoldierParams::idle;
			//reset stuff
			return;
		}

		if (soldier.state != SoldierParams::knifing)
		{ 			
			bool facing = (this.getAimPos().x <= this.getPosition().x);
			this.SetFacingLeft(facing); 
		}

		soldier.aiming_down_sight = Action2;

    	if (getCamera() is null) { return; }
		ManageCamera(this, soldier.aiming_down_sight);       
		
		if (soldier.state == SoldierParams::idle) // waiting for action
		{
			if (Action1 && gun.CLIP_AMMO > 0) 
			{				
				shoot(this, aimangle);
				soldier.action_timer = gun.FIRE_SPEED;
				soldier.state = SoldierParams::shooting;
			}
			else if(ActionReload && gun.CLIP_AMMO < gun.FULLCLIP  && gun.TOTAL_AMMO > 0) 
			{
				soldier.action_timer = gun.RELOAD_SPEED;
				soldier.state = SoldierParams::reloading;
			}
			else if (switchUp)
			{
				soldier.state = SoldierParams::switchingup;
				soldier.action_timer = SoldierParams::SwitchGunsTime;
			}
			else if (switchDown)
			{				
				soldier.state = SoldierParams::switchingdown;
				soldier.action_timer = SoldierParams::SwitchGunsTime;	
			}
			else if (CookNade && soldier.grenade_ammo > 0) 
			{
				soldier.state = SoldierParams::cookingnade;	
				soldier.action_timer = SoldierParams::CookGrenadeTime;

				if (getNet().isServer())
				{
					CBlob@ grenade = server_CreateBlob("grenade", this.getTeamNum(), this.getPosition());
					if (grenade !is null)
					{
						this.server_AttachTo(grenade, "PICKUP");
						soldier.grenade_ammo -= 1;
					}
				}
			}
			else if (ThrowNade && soldier.grenade_ammo > 0)
			{
				//client_SendThrowOrActivateCommand(this);
				soldier.state = SoldierParams::idle;
				soldier.action_timer = SoldierParams::ThrowGrenadeTime;
			}
			else if (Action3)
			{
				DoStab(this, 1.5f, aimangle, 30.0f, Hitters::sword, soldier.action_timer, soldier);
				soldier.action_timer = SoldierParams::KnifeTime;
				soldier.state = SoldierParams::knifing;
			}			
		}
		else
		{
			if (soldier.action_timer > 1) 
			{
				soldier.action_timer--;
			}
			else if (soldier.action_timer == 1)
			{
				//doAction
				switch (soldier.state)
				{
					case SoldierParams::knifing:
					{						
						soldier_clear_actor_limits(this);
					}
					case SoldierParams::switchingdown:
					{
						if (soldier.currentGunSlot == 0)
						{soldier.currentGunSlot = soldier.Guns.size()-1;}
						else
						{soldier.currentGunSlot--;}
					}
					case SoldierParams::switchingup:
					{
						if (soldier.currentGunSlot == soldier.Guns.size()-1)
						{soldier.currentGunSlot = 0;}
						else
						{soldier.currentGunSlot++;}
					}
					case SoldierParams::reloading:
					{						
						reload(this);
					}
				}
				
				soldier.state = SoldierParams::idle;
				soldier.action_timer = 0;
			}
		}

		// set cursor
		if (!getHUD().hasButtons())
		{			
			//	print("archer.charge_time " + archer.charge_time + " / " + ArcherParams::shoot_period );
			if (soldier.state == SoldierParams::reloading)
			{
				CursorFrame = 1-(soldier.action_timer/2);
			}
			else if (soldier.aiming_down_sight == true)
			{
				if (CursorFrame > 0)
				{
					CursorFrame -= 1;
				}
			}
			else
			{
				if (CursorFrame < 2)
				{
					CursorFrame += 1;
				}
				else if (CursorFrame != 2)
				{
					CursorFrame = 2;
				}


			}
			getHUD().SetCursorImage("Entities/Characters/Soldier/GUI/GunCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
			getHUD().SetCursorFrame(CursorFrame);
		}
	}
}

f32 getAimAngle(CBlob@ this) 
{
 	Vec2f blobPos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	Vec2f aimDir = blobPos-aimPos;

    return -aimDir.Angle();
}

void ManageCamera(CBlob@ this, bool ADS)
{
	CCamera@ camera = getCamera();
	CControls@ controls = this.getControls();

//	const f32 oldaimangle = this.get_f32("aimangle");
//	const Vec2f oldmousepos = this.get_Vec2f("mousepos");
//
//	Vec2f ScrMid = this.getInterpolatedPosition();	
//
//	Vec2f mousepos = controls.getMouseWorldPos()-getCamera().getInterpolationOffset();
//	Vec2f combined = mousepos - ScrMid;
//
//	f32 aimangle = -combined.Angle();
//	f32 dist = combined.Length();
//
//	f32 Adjustment = Maths::Clamp((aimangle - oldaimangle)*0.05, -0.2, 0.2);
//
//	//if (dist > 1)
//	{
//		Vec2f newpos(32, 0);
//		newpos.RotateBy(aimangle+Adjustment);
//		controls.setMousePosition(getDriver().getScreenPosFromWorldPos(ScrMid+newpos));
//
//		this.set_f32("aimangle", aimangle);
//		this.set_Vec2f("mousepos", ScrMid+newpos);
//	}


	f32 zoom = camera.targetDistance;
	bool fixedCursor = true;
	if (!ADS)  // zoomed out
	{
		camera.mousecamstyle = 1; // fixed
		//getCamera().targetDistance = 2.0;
	}
	else
	{
		camera.mousecamstyle = 2;
		//getCamera().targetDistance = 3.0;
	}
}

void DoStab(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, SoldierInfo@ soldier)
{
	if (!getNet().isServer()) { return; }	

	Vec2f stab_vec = Vec2f(1,0).RotateBy(aimangle);
	this.AddForce(stab_vec * this.getMass() * 2.4f);

	Vec2f blobPos = this.getPosition();

	Vec2f pos = blobPos+Vec2f(0, -3.5);/*+(subshoulderoffset);*/

	f32 attack_distance = 8;

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();	
	bool dontHitMore = false;

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, 33, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();
				const bool canHit = (b.hasTag("flesh") && b.getTeamNum() != this.getTeamNum());

				if (!canHit)
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (soldier_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				soldier_add_actor_limit(this, b);
				if (!dontHitMore)
				{				
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity*0.5, damage, type, true);  // server_Hit() is server-side only
					this.setVelocity(this.getVelocity()*0.2);

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
		}
	}
}

void stab(CBlob@ this, const f32 aimangle) 
{
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_f32(aimangle);
	params.write_netid(this.getNetworkID());
	this.SendCommand( this.getCommandID("Knife"), params );
}

void nade(CBlob@ this, const f32 aimangle) 
{
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_f32(aimangle);
	params.write_netid(this.getNetworkID());
	this.SendCommand( this.getCommandID("ThrowNade"), params );
}

void shoot(CBlob@ this, const f32 aimangle) 
{
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_f32(aimangle);
	params.write_netid(this.getNetworkID());
	this.SendCommand( this.getCommandID(SHOOT_CMD), params );
}

void reload(CBlob@ this) {
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_netid(this.getNetworkID());
	this.SendCommand(this.getCommandID(RELOAD_CMD), params);
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	SoldierInfo@ soldier; if (!this.get("SoldierInfo", @soldier)) { return; }
		const u8 gs = soldier.currentGunSlot;
		GunInfo@ gun = soldier.Guns[soldier.currentGunSlot]; if (gun is null) { return; }	

	if(cmd == this.getCommandID(SHOOT_CMD))
	{
		gun.Shoot(this, params);
	} 
	else if(cmd == this.getCommandID(RELOAD_CMD)) 
	{
		gun.Reload(this);
	}	
	else if (cmd == this.getCommandID("buy"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		u8 GunType = params.read_u8();

		switch (GunType)
		{
			case 0: //Pistol
			{
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
				break;
			}
			case 1: 
			{
				break;
			}
			case 2: 
			{
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
				break;
			}
			case 3: 
			{
				break;
			}

		}		
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	Vec2f vec = hitterBlob.getPosition() - this.getPosition();
	f32 angle = vec.Angle();
	
	f32 aimangle = getAimAngle(this);
	
	////////////////////////////Knockback
	f32 x_side = 0.0f;
	f32 y_side = 0.0f;
	{
		if (velocity.x > 0.7)
		{
			x_side = 1.0f;
		}
		else if (velocity.x < -0.7)
		{
			x_side = -1.0f;
		}

		if (velocity.y > 0.5)
		{
			y_side = 1.0f;
		}
		else
		{
			y_side = -1.0f;
		}
	}
	f32 scale = 1.0f;

	//scale per hitter
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::drown:
		case Hitters::burn:
		case Hitters::crush:
		case Hitters::spikes:
			scale = 0.0f; break;

		case Hitters::arrow:
			scale = 0.0f; break;

		default: break;
	}

	Vec2f f(x_side, y_side);

	if (damage > 0.125f)
	{
		this.AddForce(f * 40.0f * scale * Maths::Log(2.0f * (10.0f + (damage * 2.0f))));
	}

	if (this.isMyPlayer() && damage > 0)
    {
        SetScreenFlash( 90, 120, 0, 0 );
        ShakeScreen( 9, 2, this.getPosition() );
    }
	
	return 0;
}

void soldier_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool soldier_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 soldier_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void soldier_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void soldier_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if(blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

	if(this.isMyPlayer() && blob.hasTag("material"))
	{
		//Set Untouchable?
	}
}

