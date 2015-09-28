#==============================================================================
# ** Moving Windows
#------------------------------------------------------------------------------
# by Fantasist
# Version: 1.0
# Date: 14-Sep-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version
#------------------------------------------------------------------------------
# Description:
#
#     This script adds moving functionality to windows.
#------------------------------------------------------------------------------
# Compatibility:
#
#     Might not be compatible with other similar scripts.
#------------------------------------------------------------------------------
# Instructions:
#
#     Paste this script below "Window_Base" and above "Main".
#
#     The syntax for moving a window is:
#
#           my_window.move(dest_x, dest_y[, move_speed])
#
#     where
#           dest_x: Destination X coordinate
#           dest_y: Destination Y coordinate
#           move_speed (optional): Speed divider. Larger numbers means faster.
#
#     The attributes "dest_x", "dest_y" and "move_speed" can be used directly
#     without using the "move" function all the time.
#
#     The "moving?" function returns "true" if the windows are in motion. This
#     can be used as an event in exotic systems of all sorts :)
#------------------------------------------------------------------------------
# Issues:
#
#     None known.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Fantasist - For making this.
#------------------------------------------------------------------------------
# Notes:
#
#   If you have any questions, suggestions or comments, you can find me at:
#
#    - www.chaos-project.com
#    - www.quantumcore.forumotion.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :dest_x
  attr_accessor :dest_y
  attr_accessor :move_speed
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias move_wins_winbase_init initialize
  def initialize(x, y, width, height)
    move_wins_winbase_init(x, y, width, height)
    self.dest_x = x
    self.dest_y = y
    self.move_speed = 3
  end
  #--------------------------------------------------------------------------
  # * Moving?
  #--------------------------------------------------------------------------
  def moving?
    return (self.x != self.dest_x || self.y != self.dest_y)
  end
  #--------------------------------------------------------------------------
  # * Move
  #--------------------------------------------------------------------------
  def move(dest_x, dest_y, move_speed = nil)
    self.dest_x = dest_x
    self.dest_y = dest_y
    self.move_speed = move_speed unless move_speed.nil?
  end
  #--------------------------------------------------------------------------
  # * Move Wins
  #--------------------------------------------------------------------------
  def move_wins
    dx = (self.dest_x - self.x).to_f / self.move_speed
    dy = (self.dest_y - self.y).to_f / self.move_speed
    # Decimal correction
    dx = self.dest_x > self.x ? dx.ceil : dx.floor
    dy = self.dest_y > self.y ? dy.ceil : dy.floor
    # Moving
    self.x += dx
    self.y += dy
  end
  #--------------------------------------------------------------------------
  # * x=
  #--------------------------------------------------------------------------
  def x=(val)
    self.dest_x = val unless moving?
    super(val)
  end
  #--------------------------------------------------------------------------
  # * y=
  #--------------------------------------------------------------------------
  def y=(val)
    self.dest_y = val unless moving?
    super(val)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias move_wins_winbase_update update
  def update
    move_wins_winbase_update
    move_wins if moving?
  end
end