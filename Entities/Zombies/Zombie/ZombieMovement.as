
#define SERVER_ONLY

#include "ZombieMovementCommon.as"
#include "Knocked.as";
//#include "MakeDustParticle.as";

void onInit(CMovement@ this)
{
	ZombieMoveVars moveVars;

	float difficulty = getRules().get_f32("difficulty");
	if (difficulty<1.0) difficulty=1.0;
	if (difficulty>15.0) difficulty=15.0;
	//walking vars
	moveVars.walkSpeed = (1.0f + (1.0*(difficulty*0.1)));
	moveVars.jumpSpeed = 1.0f;
	moveVars.stoppingForce = 0.80f; //function of mass
	moveVars.moveFactor = 1.0f;

	this.getBlob().set("moveVars", moveVars);
	this.getCurrentScript().removeIfTag	= "dead"; 
	this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	ZombieMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	const bool isknocked = isKnocked(blob);

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const bool onground = blob.isOnGround() || blob.isOnLadder();	

	if (isknocked)
	{
		moveVars.moveFactor = isknocked ? 0.5f : 1.0f;
	}

	// ladder - overrides other movement completely
	if (blob.isOnLadder() && !blob.isAttached() && !blob.isOnGround() && !isknocked)
	{
		shape.SetGravityScale(0.0f);
		Vec2f ladderforce;

		if (up)
		{
			ladderforce.y = -moveVars.walkSpeed;
		}

		if (down)
		{
			ladderforce.y = moveVars.walkSpeed;
		}

		if (left)
		{
			ladderforce.x = -moveVars.walkSpeed;
		}

		if (right)
		{
			ladderforce.x = moveVars.walkSpeed;
		}

		blob.AddForce(ladderforce );
		moveVars.moveFactor = 1.0f;
		return;
	}

	shape.SetGravityScale(1.0f);
	shape.getVars().onladder = false;
	

	if (up && onground) // jumping
	{
		blob.AddForce(Vec2f(0, -moveVars.jumpSpeed * moveVars.moveFactor * 30.0f));

		TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;

		if (blob.getMap().isTileGroundStuff(tile))
		{
			blob.getSprite().PlayRandomSound("/EarthJump");
		}
		else
		{
			blob.getSprite().PlayRandomSound("/StoneJump");
		}
	}

	Vec2f walkForce;

	if (right)
	{
		walkForce.x += moveVars.walkSpeed;
	}
	else if (left)
	{
		walkForce.x -= moveVars.walkSpeed;
	}

	bool stop = true;
	if (!onground)
	{
		if (isknocked)
			stop = false;
		else if (blob.hasTag("dont stop til ground"))
			stop = false;
	}
	else
	{
		blob.Untag("dont stop til ground");
	}

	f32 force = 1.0f;
	f32 lim = 0.0f;

	{
		if (left || right)
		{
			lim = moveVars.walkSpeed;
			lim *= moveVars.moveFactor * Maths::Abs(walkForce.x);
		}

		Vec2f stop_force;

		bool greater = vel.x > 0;
		f32 absx = greater ? vel.x : -vel.x;

		bool stopped = false;
		if (absx > lim)
		{
			if (stop) //stopping
			{
				stopped = true;
				stop_force.x -= (absx - lim) * (greater ? 1 : -1);
				stop_force.x *= 30.0f * moveVars.stoppingForce;

				if (absx > 3.0f)
				{
					f32 extra = (absx - 3.0f);
					f32 scale = (1.0f / ((1 + extra) * 2));
					stop_force.x *= scale;
				}

				blob.AddForce(stop_force);
			}
		}

		if (!isknocked && ((absx < lim) || left && greater || right && !greater))
		{
			force *= moveVars.moveFactor * 30.0f;
			if (Maths::Abs(force) > 0.01f)
			{
				blob.AddForce(walkForce * force);
			}
		}
	}

	moveVars.moveFactor = 1.0f;
}

/*
// blob is an optional parameter to check collisions for, e.g. you don't want enemies to climb a trapblock
bool checkForSolidMapBlob(CMap@ map, Vec2f pos, CBlob@ blob = null)
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	@_tempBlob = map.getBlobAtPosition(pos);
	if (_tempBlob !is null && _tempBlob.isCollidable())
	{
		@_tempShape = _tempBlob.getShape();
		if (_tempShape.isStatic())
		{
			if (_tempBlob.getName() == "wooden_platform")
			{
				f32 angle = _tempBlob.getAngleDegrees();
				if (angle > 180)
					angle -= 360;
				angle = Maths::Abs(angle);
				if (angle < 30 || angle > 150)
				{
					return false;
				}
			}

			if (blob !is null && !blob.doesCollideWithBlob(_tempBlob))
			{
				return false;
			}

			return true;
		}
	}

	return false;
}

