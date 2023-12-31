// brain

namespace Strategy
{
	enum strategy_type
	{
		idle = 0,
		chasing,
		attacking
	}
}

void InitBrain(CBlob@ this)
{
	this.set_Vec2f("last pathing pos", Vec2f_zero);
	this.set_u8("strategy", Strategy::idle);
	this.getCurrentScript().removeIfTag = "dead";
}

void Repath(CBlob@ this)
{
	MapWaypoints@ waypoints;
	if (!getRules().get("MapWaypoints", @waypoints)) return;

	CBlob@ bestTarget;
	waypoints.FindPathToClosestPlayer( this.getPosition(), bestTarget );
}

bool isVisible(CBlob@blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
}

bool isVisible(CBlob@ blob, CBlob@ target, f32 &out distance)
{
	Vec2f col;
	bool visible = !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
	distance = (blob.getPosition() - col).getLength();
	return visible;
}

void JumpOverObstacles(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	const f32 radius = this.getRadius();

	if (!this.isOnLadder())
	if ((this.isKeyPressed(key_right) && (getMap().isTileSolid(pos + Vec2f(1.3f * radius, radius) * 1.0f) || this.getShape().vellen < 0.1f)) ||
	        (this.isKeyPressed(key_left)  && (getMap().isTileSolid(pos + Vec2f(-1.3f * radius, radius) * 1.0f) || this.getShape().vellen < 0.1f)))
	{
		this.setKeyPressed(key_up, true);
	}
}

void DefaultChaseBlob(CBlob@ this, CBlob@ target)
{
	//MoveAlongPath();
	JumpOverObstacles(this);
}

void FloatInWater(CBlob@ this)
{
	if (this.isInWater())
	{
		this.setKeyPressed(key_up, true);
	}
}

