Random _r(12692930456); //clientside

#include "ParticleSparks.as";
#include "MakeDustParticle.as";
#include "Hitters.as";

namespace BulletParticles
{    
    const string HITCHECK = "checkhit";

    //CMap@ map = getMap();
        //if (!getNet().isServer()) { return; }
        //CPlayer@ player = holder.getPlayer();
        //if (player is null) { return; }

        //getMap().debugRaycasts = true;

        //HitInfo@[] hitInfos;    
        //if (map.getHitInfosFromRay(pos, angle, PROJECTILE_LIFETIME, @holder, @hitInfos))
        //{
        //  for (uint i = 0; i < hitInfos.length; i++)
        //  {   
        //      if ( hitInfos.length > 0 )
        //      {   
        //          HitInfo@ hi = hitInfos[i];
        //          Vec2f hitpos = hi.hitpos;
//
        //          if (hi.blob !is null) // blob
        //          {                   
        //              if (hi.blob.hasTag("flesh") && !hi.blob.hasTag("player"))
        //              {
        //                  hi.blob.server_Hit(hi.blob, hitpos, Vec2f(0, 0), 0.1f, Hitters::arrow);
        //                  player.server_setCoins(player.getCoins() + 10);
//
        //                  for (u8 count = 0 ; count < 3+XORRandom(3); count++)
        //                  {
        //                      Vec2f vel = getRandomVelocity(0, 1.0f + 0.6f * 1 * 0.1f * XORRandom(40), 60.0f);
        //                      vel.y -= 3.0f;
//
        //                      ParticleBlood(hitpos, vel * -1.0f, SColor(255, 126, 0, 0));
        //                      ParticleBlood(hitpos, vel * 1.7f, SColor(255, 126, 0, 0));          
        //                  }
        //              }
        //          }
        //      }
        //  }
        //}

   shared void FireBullet(CBlob@ owner, Vec2f pos, Vec2f vel, f32 angle, int16 lifetime)
    {   
        EnsureRegistered();

        CParticle@ bullet = ParticleAnimated( "Bullet.png", pos, vel, angle, 0.85f, lifetime, 0, true); //ParticlePixel(pos, vel, 0xffffff00, true, lifetime);
        if(bullet !is null)
        {   
            bullet.freerotationscale = owner.getNetworkID(); // xD hacks
            //bullet.style = 1;
            //bullet.diesonanimate = true;
            bullet.gravity *= 0.01f;
            bullet.emiteffect = GetCustomEmitEffectID( "checkhit" );
            bullet.collides = false;
            bullet.diesoncollide = false; 
            bullet.Z = -10;  
            //bullet.growth = 0.6f; 
            //bullet.gravity.y = 0.4f; 
        }             
    }

    shared void EnsureRegistered()
    {     
        if(!CustomEmitEffectExists( "checkhit" ))
        {
            SetupCustomEmitEffect( "checkhit", "Bullet_Particles.as", "CheckHits", 1, 1, 120 );
        }
    }
}

shared void CheckHits(CParticle@ p)    
{
    if (!getNet().isServer()) { return; }
    CMap@ map = getMap();

    CBlob@ b = getBlobByNetworkID(p.freerotationscale);
    if (b is null) {return;}
    CPlayer@ player = b.getPlayer();
    if (player is null) {return;}

    HitInfo@[] hitInfos;
    if (map.getHitInfosFromRay(p.position-p.velocity, -p.velocity.Angle(), 6, b, @hitInfos))
    {
        for (uint i = 0; i < hitInfos.length; i++)
        {                   
            HitInfo@ hi = hitInfos[i];
            Vec2f hitpos = hi.hitpos;

            if (hi.blob !is null) // blob
            {                   
                if (hi.blob.hasTag("flesh") && !hi.blob.hasTag("player"))
                {
                    hi.blob.server_Hit(hi.blob, hitpos, Vec2f(0, 0), 0.1f, Hitters::arrow);
                    player.server_setCoins(player.getCoins() + 10);

                    for (u8 count = 0 ; count < 3+XORRandom(3); count++)
                    {
                        Vec2f vel = getRandomVelocity(0, 1.0f + 0.6f * 1 * 0.1f * XORRandom(40), 60.0f);
                        vel.y -= 3.0f;
                        ParticleBlood(hitpos, vel * -1.0f, SColor(255, 126, 0, 0));
                        ParticleBlood(hitpos, vel * 1.7f, SColor(255, 126, 0, 0));      
                    }

                    p.timeout = -1;
                }
            }
            else // hit tile
            {      
                //if( map.isTileStone(hi.tile) || map.isTileCastle(hi.tile))
                {
                    //f32 vellen = p.velocity.Length();
                    //sparks(hitpos, -p.velocity.Angle(), Maths::Max(vellen*0.05f, 0.5f));                              
                    p.timeout = -1;
                }
            }
        }
    }
}

   