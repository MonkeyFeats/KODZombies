
#include "Hitters.as";
#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const string chomp_tag = "chomping";

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    this.ReloadSprites(blob.getTeamNum(),0); 
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (this.isAnimation("bite") && !this.isAnimationEnded()) return;
    if (blob.getHealth() > 0.0)
    {
		f32 x = blob.getVelocity().x;
				
		if( blob.get_s32("climb") > 1 ) 
		{
			if (!this.isAnimation("climb")) {
				this.SetAnimation("climb");
			}
		}
		else
		if( blob.hasTag(chomp_tag) && !this.isAnimation("bite"))
		{
			if (!this.isAnimation("bite")) {
			this.PlaySound( "/ZombieAttack"+(1+XORRandom(3)) );
			this.SetAnimation("bite");
			return;
			}
		}
		else
		if (Maths::Abs(x) > 0.1f)
		{
			if (!this.isAnimation("walk")) {
				this.SetAnimation("walk");
			}
		}
		else
		{			
			if (!this.isAnimation("idle")) {
			this.SetAnimation("idle");
			}
		}
	}
}

//blob
void onInit(CBrain@ this)
{
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);
	float difficulty = getRules().get_f32("difficulty");
	if (difficulty<1.0) difficulty=1.0;
	this.set_f32("bite damage", 1.0f);
	int bitefreq = 30;
	if (bitefreq<10) bitefreq=10;
	this.set_u16("bite freq", bitefreq);
	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_f32(target_searchrad_property, 360.0f);
	this.set_f32(terr_rad_property, 185.0f);
	
	this.getShape().SetRotationsAllowed(false);	
	
	this.Tag("flesh");
	this.Tag("zombie");

	this.getShape().SetOffset(Vec2f(0,0));	
	this.server_setTeamNum(-1);
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
		
	float difficulty = getRules().get_f32("difficulty");
	
	if (getNet().isServer() && this.hasTag(chomp_tag))
	{
		u16 lastbite = this.get_u16("lastbite");
		u16 bitefreq = this.get_u16("bite freq");
		if (bitefreq<0) bitefreq=20;		
		if (lastbite > bitefreq)
		{
			float aimangle=0;
			if(this.get_u8(state_property) == MODE_TARGET )
			{
				CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
				Vec2f vel;
				if(b !is null)
				{
					vel = b.getPosition()-this.getPosition();
					
				}
				else vel = Vec2f(1,0);
				{
					vel.Normalize();
					HitInfo@[] hitInfos;
					CMap @map = getMap();
					 
					if (map.getHitInfosFromArc( this.getPosition()- Vec2f(2,0).RotateBy(-vel.Angle()), -vel.Angle(), 90, this.getRadius() + 2.0f, this, @hitInfos ))
					{						
						//HitInfo objects are sorted, first come closest hits
						for (uint i = 0; i < hitInfos.length; i++)
						{
							HitInfo@ hi = hitInfos[i];
							CBlob@ other = hi.blob;	  
							if (other !is null)
							{
								if (other.hasTag("flesh") && other.getTeamNum() != this.getTeamNum())
								{
									f32 power = this.get_f32("bite damage");
									this.server_Hit(other,hi.hitpos,vel,power,Hitters::bite, false);
									this.set_u16("lastbite",0);
								}
								else
								{
									const bool large = other.hasTag("blocks sword") && other.isCollidable();
									if (other.hasTag("large") || large || other.getTeamNum() == this.getTeamNum())
									{
										break;
									}
								}
							}
							else
							{
								break;
							}
						}
					}
					else if (XORRandom(6) == 0 && lastbite == 0)
					{
						this.getSprite().PlaySound( "/ZombieMad"+(1+XORRandom(3)) );
					}
				}		
			}
		}
		else
		{
			this.set_u16("lastbite",this.get_u16("lastbite")+1);
		}	
	}

	// footsteps
	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)) )
	{		
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min( 0.1f + Maths::Abs(this.getVelocity().x)*0.1f, 1.0f );
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( 0.0f, this.getRadius() + 4.0f )).type;

			if (this.getMap().isTileGroundStuff( tile )) {
				this.getSprite().PlaySound("/EarthStep", volume, 0.75f );
			}
			else {
				this.getSprite().PlaySound("/StoneStep", volume, 0.75f );
			}
		}
	}
	
	if(getNet().isServer() && getGameTime() % 10 == 0)
	{
		if(this.get_u8(state_property) == MODE_TARGET )
		{
			CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
			if(b !is null && this.getDistanceTo(b) < 40.0f)
			{
				this.Tag(chomp_tag);
			}
			else
			{
				this.Untag(chomp_tag);
			}
		}
		else
		{
			this.Untag(chomp_tag);
		}
		this.Sync(chomp_tag,true);
	}
	
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{				
    this.Damage( damage, hitterBlob );

    if (this.getHealth() <= 0)
    {
        this.getSprite().Gib();
		//server_DropCoins(hitterBlob.getPosition() + Vec2f(0,-3.0f), 10);		
        this.server_Die();
    }		
    return 0.0f; //done, we've used all the damage		
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
/*	if (hitBlob !is null)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 1.0f;
		hitBlob.AddForce( force);
	}*/
}

void onDie( CBlob@ this )
{
	//CBlob@ powerup = server_CreateBlob( "powerup", 0, this.getPosition()+Vec2f(0,-4));
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       1, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   1, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{	
	if (blob.hasTag("zombie") && blob.getHealth()<0.0) return false;
	return true;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
