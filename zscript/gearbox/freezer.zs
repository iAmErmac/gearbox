/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020-2021
 *
 * This file is part of Gearbox.
 *
 * Gearbox is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Gearbox is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Gearbox.  If not, see <https://www.gnu.org/licenses/>.
 */

class gb_Freezer play
{

  static
  gb_Freezer from(gb_Options options)
  {
    let result = new("gb_Freezer");
    result.mWasFrozen = false;
    result.mOptions   = options;
    result.mWasLevelFrozen = false;
    return result;
  }

  void freeze()
  {
    if (mWasFrozen) return;
    mWasFrozen = true;

    int freezeMode = mOptions.getTimeFreezeMode();
    if (isLevelFreezeEnabled (freezeMode)) freezeLevel();
    //if (isPlayerFreezeEnabled(freezeMode)) freezePlayer();
  }

  void thaw()
  {
    if (!mWasFrozen) return;
    mWasFrozen = false;

    if (isLevelThawEnabled()) thawLevel();
    //thawPlayer();
  }

  void fadeoutInvulnerability()
  {
	//This is to disable invulnerability after wheel close when loaded with bullet-time-x mod
	if(mWheelCloseCounter > 0)
	{
		mWheelCloseCounter--;
	}
	else if(mWheelCloseCounter == 0)
	{
		bool playerSlowMoInvulnerable = mOptions.getTimeFreezeInvMode();
		if(playerSlowMoInvulnerable) players[consoleplayer].mo.bInvulnerable = false;
		mWheelCloseCounter = -1;
	}
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  /**
   * Corresponds to gb_FreezeValues in menudef.
   */
  private static
  bool isLevelFreezeEnabled(int freezeMode)
  {
    return !multiplayer && (freezeMode == 1);
  }

  /**
   * Corresponds to gb_FreezeValues in menudef.
   *
   * Freezing level without player causes weird behavior, like weapon bobbing
   * while Gearbox is open. So, freeze player when level is frozen too.
   */
  private static
  bool isPlayerFreezeEnabled(int freezeMode)
  {
    return freezeMode != 0;
  }

  /**
   * Thaw regardless of freeze mode.
   */
  private static
  bool isLevelThawEnabled()
  {
    return !multiplayer;
  }

  private
  void freezeLevel()
  {
    //mWasLevelFrozen = level.isFrozen();
    //level.setFrozen(true);
	
	if(mWasLevelFrozen) return;
	
	PlayerInfo player = players[consolePlayer];
	
	bool useSlowMo = mOptions.getTimeSlowMode();
	bool useSlowMoSound = mOptions.getTimeSlowSound();
	
	bool playerSlowMoInvulnerable = mOptions.getTimeFreezeInvMode();
	if(playerSlowMoInvulnerable) players[consoleplayer].mo.bInvulnerable = true; //Make player invulnerable during freeze/slow-mo
	
	string btClassName = "BulletTime";
	class<EventHandler> btLoaded = btClassName;
	
	if(btLoaded && useSlowMo)
	{
		gb_EventHandler.SendNetworkEvent("btRemoteActivate", useSlowMoSound, 20);
		return;
	}
	
	if(!player.mo.CountInv("gPowerTimeFreezeColor")) player.mo.GiveInventory("CustomTimeFreezerColor", 1);
	if(useSlowMoSound) player.mo.A_StartSound("SLWSTART",  0, CHANF_LOCAL, 1.0, ATTN_NONE, 1.0);
	freezeActors();
	
	mWasLevelFrozen = true;
  }
  
  void freezeActors()
  {
	bool useSlowMo = mOptions.getTimeSlowMode();
	string btClassName = "BulletTime";
	class<EventHandler> btLoaded = btClassName;
	if(btLoaded && useSlowMo) return;
	
	ThinkerIterator It = ThinkerIterator.Create();
	Actor Mo;
	While (Mo = Actor(It.Next()))
	{
		If (Mo && (Mo.bISMONSTER || Mo.bMISSILE) && Mo.health > 0)
		{
			//if the actor is marked for frozen mmake sure to keep frozen
			if(!Mo.CountInv("timeFreezeCustomMarker") && !Mo.CountInv("timeSlowCustomMarker"))
			{
				if(useSlowMo)
				{
					Mo.GiveInventory("timeSlowCustomMarker", 1);
					Vector3 mVel = Mo.vel;
					Int mGravity = Mo.gravity;
					let moInfo = timeSlowCustomMarker(Mo.FindInventory("timeSlowCustomMarker"));
					moInfo.mVel = mVel;
					moInfo.mGravity = mGravity;
				}
				else
				{
					Mo.GiveInventory("timeFreezeCustomMarker", 1);
					Vector3 mVel = Mo.vel;
					Int mGravity = Mo.gravity;
					Let moInfo = timeFreezeCustomMarker(Mo.FindInventory("timeFreezeCustomMarker"));
					moInfo.mVel = mVel;
					moInfo.mGravity = mGravity;
				}
			}
		}
	}
  }

  void freezePlayer()
  {
    mWasPlayerFrozen = true;

    PlayerInfo player = players[consolePlayer];
	
	player.vel = (0, 0);
	player.mo.vel = (0, 0, 0);
	player.mo.gravity = 0;

	/*
    mCheats   = player.cheats;
    mVelocity = player.mo.vel;
    mGravity  = player.mo.gravity;

    gb_Sender.sendFreezePlayerEvent(player.cheats | FROZEN_CHEATS_FLAGS, (0, 0, 0), 0);
	*/
  }

  private
  void thawLevel() const
  {
    //level.setFrozen(mWasLevelFrozen);
	
	PlayerInfo player = players[consolePlayer];
	
	bool useSlowMo = mOptions.getTimeSlowMode();
	bool useSlowMoSound = mOptions.getTimeSlowSound();
	
	mWheelCloseCounter = 52; //This counter will make sure invulnerability is disabled when wheel is closed
	
	string btClassName = "BulletTime";
	class<EventHandler> btLoaded = btClassName;
	
	if(btLoaded)
	{
		gb_EventHandler.SendNetworkEvent("btRemoteDeactivate", useSlowMoSound);
	}
	
	player.mo.TakeInventory("gPowerTimeFreezeColor", 99);
	if(useSlowMoSound) player.mo.A_StartSound("SLWSTOP",  0, CHANF_LOCAL, 1.0, ATTN_NONE, 1.0);
	thawActors();
	
	mWasLevelFrozen = false;
  }
  
  void thawActors()
  {
	ThinkerIterator It = ThinkerIterator.Create();
	Actor Mo;
	While (Mo = Actor(It.Next()))
	{
		if(Mo.CountInv("timeFreezeCustomMarker") > 0)
		{
			let moInfo =  timeFreezeCustomMarker(Mo.FindInventory("timeFreezeCustomMarker"));
			Vector3 mVel = moInfo.mVel;
			Int mGravity = moInfo.mGravity;
			moInfo.destroy();
			Mo.tics = 1;
			Mo.vel = mVel;
			Mo.gravity = mGravity;
		}
		if(Mo.CountInv("timeSlowCustomMarker") > 0)
		{
			let moInfo =  timeSlowCustomMarker(Mo.FindInventory("timeSlowCustomMarker"));
			Vector3 mVel = moInfo.mVel;
			Int mGravity = moInfo.mGravity;
			moInfo.destroy();
			Mo.tics = 1;
			Mo.vel = mVel;
			Mo.gravity = mGravity;
		}
	}
  }

  void thawPlayer() const
  {
    //if (mWasPlayerFrozen) gb_Sender.sendFreezePlayerEvent(mCheats, mVelocity, mGravity);
	
    PlayerInfo player = players[consolePlayer];
	
	player.vel = player.mo.default.vel.xy;
	player.mo.vel = player.mo.default.vel;
	player.mo.gravity = player.mo.default.gravity;
		
    mWasPlayerFrozen = false;
  }

  const FROZEN_CHEATS_FLAGS  = CF_TotallyFrozen | CF_Frozen;

  private bool    mWasFrozen;

  private bool    mWasLevelFrozen;
  private bool    mWasPlayerFrozen;
  Array<int> projectileVelX, projectileVelY, projectileVelZ;
  private int     mWheelCloseCounter;

  private int     mCheats;
  private vector3 mVelocity; // to reset weapon bobbing.
  private double  mGravity;

  private gb_Options mOptions;

} // class gb_Freezer



Class timeFreezeCustomMarker : Inventory
{
	Default
	{
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		+INVENTORY.UNCLEARABLE;
		+INVENTORY.PERSISTENTPOWER;
		inventory.maxamount 1;
	}
	
	Override Void DoEffect()
	{
		super.DoEffect();
		if(!owner) destroy();
		
		owner.tics = -1;
		owner.gravity = 0;
		owner.vel = (0, 0, 0);
	}
	
	Vector3 mVel;
	Int mGravity;
}

Class timeSlowCustomMarker : timeFreezeCustomMarker
{
	Default
	{
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		+INVENTORY.UNCLEARABLE;
		+INVENTORY.PERSISTENTPOWER;
		inventory.maxamount 1;
	}
	
	Override Void DoEffect()
	{
		super.DoEffect();
		if(!owner) destroy();
		
		if(slowDelay < 11)
		{
			owner.tics = -1;
			owner.gravity = 0;
			owner.vel = (0, 0, 0);
			slowDelay++;
		}
		else if(slowDelay == 11)
		{
			owner.tics = 1;
			owner.vel = mVel;
			owner.gravity = mGravity;
			slowDelay = 0;
		}
	}
	
	Int slowDelay;
}

Class CustomTimeFreezerColor : PowerupGiver
{
	Default
	{
		Inventory.MaxAmount 0;
		Powerup.Type "gPowerTimeFreezeColor";
		Powerup.Duration 0x7FFFFFFD;
		+INVENTORY.AUTOACTIVATE;
	}
	States
	{
	Spawn:
		MEGA ABCD 4 bright;
		Loop;
	}
}

Class gPowerTimeFreezeColor : Powerup
{
	Default
	{
		Powerup.Color "F5 FB FF", 0.15;
		Powerup.Duration 0x7FFFFFFD;
	}
}