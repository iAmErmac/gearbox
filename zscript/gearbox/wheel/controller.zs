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

class gb_WheelController
{

  static
  gb_WheelController from(gb_Options options, gb_Screen screen)
  {
    let result = new("gb_WheelController");

    result.reset();
    result.mScreen  = screen;
    result.mOptions = options;

    return result;
  }

  void reset()
  {
    mX = 0;
    mY = 0;

    PlayerInfo player = players[consolePlayer];
    mStartPitch = player.mo.pitch;
    mStartYaw   = player.mo.angle;
  }

  void fill(out gb_WheelControllerModel model)
  {
    model.angle  = getAngle();
    model.radius = getRadius();
  }

  play
  void process() const
  {
    if (!mOptions.isMouseInWheel()) return;

    PlayerInfo player = players[consolePlayer];
	
	//This will let us use joystick as mouse
	let joypad_speed = Int(mOptions.getWheelScale() * 40);
	let pos = joypad_speed * (
			15.0 * player.original_cmd.sidemove		/ 10240,
		-	15.0 * player.original_cmd.forwardmove	/ 12800);
	
	mX = pos.x;
	mY = pos.y;

    vector2 center = mScreen.getWheelCenter();
    int centerX = int(center.x);
    int centerY = int(center.y);
    mX = clamp(mX, -centerX, Screen.getWidth()  - centerX);
    mY = clamp(mY, -centerY, Screen.getHeight() - centerY);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  double getAngle() const
  {
    return -atan2(mX, mY) + 180;
  }

  private
  double getRadius() const
  {
    return sqrt(mX * mX + mY * mY);
  }

  private int mX;
  private int mY;

  private double mStartPitch;
  private double mStartYaw;

  private gb_Screen  mScreen;
  private gb_Options mOptions;

} // class gb_WheelController
