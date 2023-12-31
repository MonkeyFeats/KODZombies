#include "Hitters.as";
#include "Bullet_Particles.as";
//#include "StandardFire.as";
//#include "GunStandard";

shared enum GunType
{
	None = 0,
	Pistol,
	Shotty,
	Rifle,
	Sniper,
	Launcher,
	DeathMachine
}

const string[] GunNames =
{
	"Colt",
	"Revolver",
	"Olympia",
	"Spaz",
	"M16",
	"MP40",
	"RayGun",
	"Famas"
};

shared enum BulletType
{
	HitScan = 0,
	HitScanPenetrating,
	Projectile
}

shared enum ReloadType
{
	OneAtATime = 0,
	TwoAtATime,
	Full
}

shared enum FireMode
{
	Single = 0,
	Burst,
	Auto
}

shared class GunInfo
{
	uint8  FIRE_SPEED;
	uint8  RELOAD_SPEED;

	uint8  PROJECTILE_SPEED;	
	uint8  PROJECTILE_COUNT;
	uint8  PROJECTILE_SPREAD;
	int16  PROJECTILE_LIFETIME;
	float  BULLET_DAMAGE;

	Vec2f  RECOIL_FORCE;
	uint8  RECOIL_TIMER;
	float  RECOIL_SCALE;

	uint8  FULLCLIP;
	uint8  CLIP_AMMO; 
	uint8  TOTAL_AMMO;

	GunType GUNTYPE;
	FireMode FIREMODE;
	ReloadType RELOADTYPE;
	string AMMO_TYPE;

	string EMPTY_CLIP_SOUND = "EmptyClip.ogg";
	string PICKUP_GUN_SOUND = "PickupGun.ogg";
	string FIRE_SOUND;
	string RELOAD_SOUND;
	uint8  SPRITE_FRAME;

	Vec2f  BARREL_OFFSET;

	GunInfo() {}

	void Shoot(CBlob@ holder, CBitStream@ params)
	{
		this.CLIP_AMMO--;

		Vec2f pos = params.read_Vec2f();
		f32 angle = params.read_f32();

		Vec2f barreloff = this.BARREL_OFFSET;
		barreloff.RotateBy(angle, Vec2f(0, -3.5f));

		for (int i = 0; i < this.PROJECTILE_COUNT; i++)
		{						
			Vec2f vel = getRandomVelocity( angle, this.PROJECTILE_SPEED, this.PROJECTILE_SPREAD);			
			BulletParticles::FireBullet( holder, pos+barreloff, vel , angle, this.PROJECTILE_LIFETIME);
		}

		playSound(holder, this.FIRE_SOUND);
	}

	void Reload(CBlob@ holder)
	{
		u8 currentTotalAmount = this.TOTAL_AMMO;
		u8 currentClipAmount = this.CLIP_AMMO;
		u8 neededClipAmount = this.FULLCLIP - currentClipAmount;
		
		if(currentTotalAmount >= neededClipAmount) 
		{
			this.CLIP_AMMO = this.FULLCLIP;
			currentTotalAmount -= neededClipAmount;
			this.TOTAL_AMMO = currentTotalAmount;
		} 
		else 
		{
			this.CLIP_AMMO = currentTotalAmount;
			currentTotalAmount = 0;
			this.TOTAL_AMMO = currentTotalAmount;
		}

		playSound(holder, this.RELOAD_SOUND);
	}	

	void playSound(CBlob@ this, string soundName) 
	{
		CSprite@ sprite = this.getSprite();
		if(sprite !is null) 
		{
			sprite.PlaySound(soundName);
		}
	}
};

shared class ColtPistol : GunInfo
{
	ColtPistol()
	{
		FIRE_SPEED = 4;
		RELOAD_SPEED = 60;

		BULLET_DAMAGE = 0.2; 
		PROJECTILE_SPEED = 14; 
		PROJECTILE_LIFETIME = 12;
		PROJECTILE_COUNT = 1;
		PROJECTILE_SPREAD = 1;

		FULLCLIP = 7;
		CLIP_AMMO = FULLCLIP; 
		TOTAL_AMMO = 80;

		GUNTYPE = GunType::Pistol;
		FIREMODE = FireMode::Single;
		RELOADTYPE = ReloadType::Full;

		AMMO_TYPE = "bullet";
		FIRE_SOUND = "PistolFire.ogg";
		RELOAD_SOUND  = "Reload.ogg";

		RECOIL_FORCE = Vec2f(-1.0f,0.0);
		RECOIL_SCALE = 0.8;
		BARREL_OFFSET = Vec2f(0.0f,-2.0);

		SPRITE_FRAME = 0;
	}	
};

shared class MagnumPistol : GunInfo
{
	MagnumPistol()
	{
		BULLET_DAMAGE = 0.2; 
		PROJECTILE_SPEED = 20; 
		PROJECTILE_LIFETIME = 0.6; 

		FULLCLIP = 6;
		CLIP_AMMO = FULLCLIP; 
		TOTAL_AMMO = 56;
		RELOAD_SPEED = 6;

		GUNTYPE = GunType::Pistol;
		FIREMODE = FireMode::Single;
		RELOADTYPE = ReloadType::OneAtATime;

		AMMO_TYPE = "bullet";
		FIRE_SOUND = "PistolFire.ogg";
		RELOAD_SOUND  = "Reload.ogg";

		RECOIL_FORCE = Vec2f(-1.0f,0.0);
		RECOIL_SCALE = 0.8;
		BARREL_OFFSET = Vec2f(-8.0f,2.0);

		SPRITE_FRAME = 1;
	}	
};

shared class SpazShotgun : GunInfo
{
	SpazShotgun()
	{
		BULLET_DAMAGE = 0.2; 
		PROJECTILE_SPEED = 5; 
		PROJECTILE_LIFETIME = 10; 
		PROJECTILE_COUNT = 6;
		PROJECTILE_SPREAD = 10;

		FULLCLIP = 7;
		CLIP_AMMO = FULLCLIP; 
		TOTAL_AMMO = 48;
		RELOAD_SPEED = 7;

		GUNTYPE = GunType::Shotty;
		FIREMODE = FireMode::Single;
		RELOADTYPE = ReloadType::OneAtATime;

		AMMO_TYPE = "bullet";
		FIRE_SOUND = "PistolFire.ogg";
		RELOAD_SOUND  = "Reload.ogg";

		RECOIL_FORCE = Vec2f(-6.0f,0.0);
		BARREL_OFFSET = Vec2f(0.0f,2.0);

		SPRITE_FRAME = 5;
	}
};

shared class Olympia : GunInfo
{
	Olympia()
	{
		FIRE_SPEED = 12;
		BULLET_DAMAGE = 1.0; 
		PROJECTILE_SPEED = 15; 
		PROJECTILE_LIFETIME = 8; 
		PROJECTILE_COUNT = 6;
		PROJECTILE_SPREAD = 6;

		FULLCLIP = 2;
		CLIP_AMMO = FULLCLIP; 
		TOTAL_AMMO = 48;
		RELOAD_SPEED = 60;

		GUNTYPE = GunType::Shotty;
		FIREMODE = FireMode::Single;
		RELOADTYPE = ReloadType::OneAtATime;

		AMMO_TYPE = "bullet";
		FIRE_SOUND = "PistolFire.ogg";
		RELOAD_SOUND  = "Reload.ogg";

		RECOIL_FORCE = Vec2f(-6.0f,0.0);
		BARREL_OFFSET = Vec2f(0.0f,-2.0);

		SPRITE_FRAME = 4;
	}
};