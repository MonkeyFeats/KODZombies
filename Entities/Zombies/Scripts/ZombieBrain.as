//brain

#define SERVER_ONLY

#include "KODBrainCommon.as";
#include "PressOldKeys.as";
#include "AnimalConsts.as";
#include "MapWaypoints.as";

CBlob@ thisBlob;

void onInit( CBlob@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	
} 

void onTick( CBlob@ this )
{
	MapWaypoints@ waypoints;
	if (!getRules().get("MapWaypoints", @waypoints)) return;
	Vec2f pos = this.getPosition();		

	u8 delay = this.get_u8(delay_property);	

	if (delay == 0)
	{
		delay = 10;

		CBlob@ bestTarget;
		Path@ bestPath = waypoints.FindPathToClosestPlayer(pos, bestTarget);

		if (bestPath !is null && bestTarget !is null)
		{
			this.set_netid(target_property, bestTarget.getNetworkID());
			this.set("currentPath", @bestPath);
		}
	}
	delay--;
	this.set_u8(delay_property, delay);	

	Path@ currentPath;
	if (!this.get("currentPath", @currentPath)) return;

	CBlob@ targetblob = getBlobByNetworkID(this.get_netid(target_property));
	
	if (targetblob !is null && currentPath !is null && currentPath.Nodes.size() > 0)
	{
		Vec2f nextPos = currentPath.Nodes[1].Position; // zombies re-check paths fast enough to be able to do this.. atm

		this.setAimPos(nextPos);	

		this.setKeyPressed(key_right, false);
		this.setKeyPressed(key_left, false);
		this.setKeyPressed(key_up, false);
		this.setKeyPressed(key_down, false);

		if (pos.y > nextPos.y+16)
		{
			this.setKeyPressed(key_up, true);
		}
		else if (pos.y < nextPos.y-16)
		{
			this.setKeyPressed(key_down, true);
		}

		if (pos.x > nextPos.x+4)
		{
			this.setKeyPressed(key_left, true);
		}
		else if ( pos.x < nextPos.x-4)
		{
			this.setKeyPressed(key_right, true);
		}
	}
}