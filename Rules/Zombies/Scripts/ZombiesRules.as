#define SERVER_ONLY

class ZombieSpawnSetup
{
	string name;		//name used for spawning
	float value;		//value used to determine wave size
	ZombieSpawnSetup(string n, float v)
	{
		name = n;
		value = v;
	}
};

/////////////////////////////////////////
//global zombies variables
f32 nextwavetime;

int round;
int gameovertimer;
u16 roundzombiescount;
bool newround;

const ZombieSpawnSetup[] zombies =
{
	//ZombieSpawnSetup("ZombieKnight", 5.0f),	
	//ZombieSpawnSetup("Greg", 3.0f),
	ZombieSpawnSetup("Zombie", 1.0f),
	//ZombieSpawnSetup("Skeleton", 1.0f),
};

void onTick(CRules@ this)
{
	//checks run every now and then to avoid gumming up performance too much
	if (getGameTime() % 11 != 0)
	{
		return;
	}
	//get everything we need for a frame

	CMap@ map = getMap();
	CPlayer@[] players = collectPlayers(this);

	//respawn players
	if (this.isWarmup())
	{
		CPlayer@[] dead = filterNeedRespawn(players);
		if (dead.length > 0)
		{
			DoRespawns(dead);
		}
	}

	if (this.isWarmup())
	{
		//if has at least one player, and is night time, set game on!
		if (players.length > 0)
		{
			round = 0;
			this.set_u8("round", round);
			Sound::Play("NewGame.ogg");
			this.SetCurrentState(0); // round intermission
		}
	}
	else if (this.isIntermission())
	{				

		u8 timer = this.get_u8("intermission timer");
		timer++;
		this.set_u8("intermission timer", timer);	

		if (timer == 1 && round > 0)
		{
			Sound::Play("NewRound.ogg");
		}	
		if (timer == 3)
		{
			round += 1;
			this.set_u8("round", round);
		}		
		if (timer >= 6)
		{
			newround = true;
			nextwavetime = 0.0f; //spawn immediately when time to spawn
			this.SetCurrentState(GAME); // round intermission
		}	

		if (map !is null && map.getDayTime() < 9.94f)
		{
			//if (timer >= 5)
			{
				map.SetDayTime( map.getDayTime() + (0.0025f)); // 20 days to midnight
				//print(""+map.getDayTime());
			}
		}			
	}
	else if (this.isMatchRunning())
	{
		//reset variables at the start of each round
		if (newround)
		{
			
			roundzombiescount = (1*round)*getPlayersCount();
			newround = false;
		
			//nextwavetime = 0.0f;
		}
		//if time to spawn
		//else if (midnight)
		{
			//spawn zombies if it's time for a wave
			//if (current_time >= nextwavetime)
			{
				SpawnZombieWave(this);
				nextwavetime += 1.0f;		//for now, only one wave
			}
		}

		CBlob@[] zombiesalive;
		getBlobsByTag( "zombie", @zombiesalive );
		if (zombiesalive.length == 0 && roundzombiescount == 0)
		{
			this.set_u8("intermission timer", 0);
			this.SetCurrentState(0); // round intermission
		}

		//if everyone's dead
		//note: automatically triggered if everyone leaves
		//      or join
		if (gameovertimer == -1)
		{
			CPlayer@[] dead = filterNeedRespawn(players);
			if (dead.length == players.length)
			{
				//10 seconds of gameover timer
				//gameovertimer = 30 * 10;
				
				//5 seconds of gameover timer
				//Changed from 30 * 5 to 30 * 2
				gameovertimer = 30 * 2;
				this.SetTeamWon(1); //zombies win
				this.SetCurrentState(GAME_OVER);
			}
		}
	}
	else if (this.isGameOver())
	{
		this.SetGlobalMessage( "No one survived... the Zombies have won. You survived: "+ round + " rounds."); // End of game message. TODO add an if statement for grammar
		//count down timer
		gameovertimer--;
		//if timer over
		if (gameovertimer == 0)
		{
			LoadNextMap();
		}
	}
}


//do the zombie spawn logic
void SpawnZombieWave(CRules@ this)
{
	//new random, seeded by time (different each wave/game)
	Random _zombieRandom(Time());

	if (roundzombiescount > 0)
	{		
		SpawnZombie("Zombie", randomEdgePosition());
		roundzombiescount--;
	}
}

//intialisation
//reset anything that needs to be reset
void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	gameovertimer = -1;
	round = 0;
	this.SetCurrentState(WARMUP);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(0);
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (newteam != this.getSpectatorTeamNum())
		newteam = 0;

	KillOwnedBlob(player);
	player.server_setTeamNum(newteam);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	KillOwnedBlob(player);
}

void SpawnPlayer(CPlayer@ p, Vec2f pos)
{
	CBlob@ b = server_CreateBlob("soldier", 0, pos);
	b.server_SetPlayer(p);
}

void SpawnZombie(string name, Vec2f pos)
{
	server_CreateBlob( name, 1, pos);
}

/////////////////////////////////////////
//helper functions

Random _edgeRandom();
Vec2f randomEdgePosition()
{
	const s32 edgeVariation = 20; //range that you can spawn in of the edge, in tiles

	CMap@ map = getMap();
	s32 x = 1;
	//if (_edgeRandom.NextRanged(2) == 0)
	//{
	//	x = (map.tilemapwidth - 2);
	//	x -= _edgeRandom.NextRanged(edgeVariation);
	//}
	//else
	{
		x += edgeVariation;
	}
	s32 y = map.getLandYAtX(x) - 8;
	return Vec2f((x + 0.5f) * map.tilesize, (y + 0.5f) * map.tilesize);
}

Vec2f PlayerSpawnPosition()
{
	CBlob@[] points;
	getBlobsByTag("respawn", @points);

	for (uint i = 0; i < points.length; i++)
	{
		CBlob@ point = points[i];
		if (point !is null)
		{
			return point.getPosition();
		}
	}

	return Vec2f(0, 0);
}

//collect players actually playing the game
//aka not spectators
CPlayer@[] collectPlayers(CRules@ this)
{
	CPlayer@[] players;
	for (uint i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getTeamNum() != this.getSpectatorTeamNum())
		{
			players.push_back(p);
		}
	}
	return players;
}

//get players that need a respawn (dont have a blob)
CPlayer@[] filterNeedRespawn(CPlayer@[] players)
{
	CPlayer@[] filtered;
	for (uint i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		if (p.getBlob() is null)
		{
			filtered.push_back(p);
		}
	}
	return filtered;
}

//do the respawns for a set of players that need it
void DoRespawns(CPlayer@[] players)
{
	for (uint i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		Vec2f pos = PlayerSpawnPosition();
		//TODO: respawn the player at pos here
		SpawnPlayer(p, pos);
	}
}

//kill the blob if they have one (on switching team, or leaving)
void KillOwnedBlob(CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}

