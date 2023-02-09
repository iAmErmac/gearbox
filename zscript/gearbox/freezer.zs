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
	
	projectileVelX.Clear();
	projectileVelY.Clear();
	projectileVelZ.Clear();
		
	ThinkerIterator It = ThinkerIterator.Create();
	Actor Mo;
	While (Mo = Actor(It.Next()))
	{
		If (Mo && (Mo.bISMONSTER || Mo.bMISSILE) && mo.health > 0)
		{
			Mo.tics = -1;
			Mo.gravity = 0;
			
			if(Mo.bMISSILE)
			{
				projectileVelX.Push(Mo.vel.x);
				projectileVelY.Push(Mo.vel.y);
				projectileVelZ.Push(Mo.vel.z);
			}
			
			Mo.vel = (0, 0, 0);
		}
	}
	
	mWasLevelFrozen = true;
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
	
	bool useSlowMo = mOptions.getTimeSlowMode();
	bool useSlowMoSound = mOptions.getTimeSlowSound();
	
	mWheelCloseCounter = 52; //This counter will make sure invulnerability is disabled when wheel is closed
	
	string btClassName = "BulletTime";
	class<EventHandler> btLoaded = btClassName;
	
	if(btLoaded)
	{
		gb_EventHandler.SendNetworkEvent("btRemoteDeactivate", useSlowMoSound);
	}
		
	ThinkerIterator It = ThinkerIterator.Create();
	Actor Mo;
	Int mCount = 0;
	While (Mo = Actor(It.Next()))
	{
		If (Mo && (Mo.bISMONSTER || Mo.bMISSILE) && mo.health > 0)
		{
			Mo.tics = 1;
			Mo.gravity = Mo.default.gravity;
			if(!Mo.bMISSILE) Mo.vel = Mo.default.vel;
			
			if(Mo.bMISSILE && projectileVelX.size())
			{
				Mo.vel.x = projectileVelX[mCount];
				Mo.vel.y = projectileVelY[mCount];
				Mo.vel.z = projectileVelZ[mCount];
				mCount++;
			}
		}
	}
	
	projectileVelX.Clear();
	projectileVelY.Clear();
	projectileVelZ.Clear();
	
	mWasLevelFrozen = false;
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
