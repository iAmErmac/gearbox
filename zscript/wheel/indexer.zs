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

class gb_WheelIndexer
{

  static
  gb_WheelIndexer from()
  {
    let result = new("gb_WheelIndexer");
    result.mSelectedIndex = UNDEFINED_INDEX;
    result.mLastSlotIndex = UNDEFINED_INDEX;
    result.mInnerIndex    = UNDEFINED_INDEX;
    result.mOuterIndex    = UNDEFINED_INDEX;
    return result;
  }

  int getSelectedIndex() const { return mSelectedIndex; }

  int getInnerIndex() const { return mInnerIndex; }
  int getOuterIndex() const { return mOuterIndex; }

  void update(gb_ViewModel viewModel, gb_WheelControllerModel controllerModel)
  {
    if (controllerModel.radius < DEAD_RADIUS)
    {
      mSelectedIndex = UNDEFINED_INDEX;
      mLastSlotIndex = UNDEFINED_INDEX;
      mInnerIndex    = UNDEFINED_INDEX;
      mOuterIndex    = UNDEFINED_INDEX;
      return;
    }

    uint nWeapons       = viewModel.tags.size();
    bool multiWheelMode = (nWeapons > 12);

    if (!multiWheelMode)
    {
      mSelectedIndex = gb_WheelInnerIndexer.getSelectedIndex(nWeapons, controllerModel);
      mLastSlotIndex = UNDEFINED_INDEX;
      mInnerIndex    = mSelectedIndex;
      mOuterIndex    = UNDEFINED_INDEX;
      return;
    }

    gb_MultiWheelModel multiWheelModel;
    gb_MultiWheel.fill(viewModel, multiWheelModel);

    uint nPlaces = multiWheelModel.data.size();

    if (controllerModel.radius < WHEEL_RADIUS)
    {
      int  innerIndex = gb_WheelInnerIndexer.getSelectedIndex(nPlaces, controllerModel);
      bool isWeapon   = multiWheelModel.isWeapon[innerIndex];

      mSelectedIndex = isWeapon ? multiWheelModel.data[innerIndex] : UNDEFINED_INDEX;
      mLastSlotIndex = isWeapon ? UNDEFINED_INDEX : innerIndex;
      mInnerIndex    = innerIndex;
      mOuterIndex    = 0;
    }
    else
    {
      if (mLastSlotIndex == UNDEFINED_INDEX)
      {
        mSelectedIndex = UNDEFINED_INDEX;
        mInnerIndex    = UNDEFINED_INDEX;
        mOuterIndex    = UNDEFINED_INDEX;
        return;
      }

      int slot = multiWheelModel.data[mLastSlotIndex];

      uint start = 0;
      for (; start < nWeapons && viewModel.slots[start] != slot; ++start);
      uint end = start;
      for (; end < nWeapons && viewModel.slots[end] == slot; ++end);
      uint nWeaponsInSlot = end - start;

      double slotAngle = itemAngle(nPlaces, mLastSlotIndex);

      double r = controllerModel.radius;
      double w = WHEEL_RADIUS;
      double forSlotAngle = slotAngle - controllerModel.angle;
      double side  = sqrt(r * r + w * w - 2 * r * w * cos(forSlotAngle));
      double angle = -asin(r / side * sin(forSlotAngle));

      angle += 90;
      angle %= 180;

      int indexInSlot = int((angle * nWeaponsInSlot / 180.0) % nWeaponsInSlot);

      mSelectedIndex = start + indexInSlot;
      mInnerIndex    = mLastSlotIndex;
      mOuterIndex    = indexInSlot;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  double itemAngle(uint nItems, uint index)
  {
    return 360.0 / nItems * index;
  }

  const DEAD_RADIUS  = 67;
  const WHEEL_RADIUS = 270;

  const UNDEFINED_INDEX = -1;

  private int mSelectedIndex;

  private int mLastSlotIndex;
  private int mInnerIndex;
  private int mOuterIndex;

} // class gb_WheelIndexer
