
#include "Guns.as";

namespace SoldierParams
{
	enum States
	{
		idle = 0,
		shooting,
		knifing,
		cookingnade,
		throwingnade,
		switchingup,
		switchingdown,
		reloading,
		bleedingout
	}

	const ::u16 SwitchGunsTime = 45; // put this in guns info, for individual gun times
	const ::u16 KnifeTime = 24;
	const ::u16 CookGrenadeTime = 45;
	const ::u16 ThrowGrenadeTime = 10;
}

shared class SoldierInfo
{
	u8 state;
	u16 action_timer;

	GunInfo[] Guns;
	u8 currentGunSlot;

	u8 knifeType;
	u8 grenade_type;
	u8 grenade_ammo;

	bool aiming_down_sight;

	SoldierInfo()
	{
		state = SoldierParams::idle;
		action_timer = 0;
		currentGunSlot = 0;
		grenade_ammo = 2;
	}
};