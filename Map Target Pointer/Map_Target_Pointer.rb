#==============================================================================
# ** Map Target Pointer
#------------------------------------------------------------------------------
# by Fantasist
# Version: 1.0
# Date: 30-Jan-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version
#------------------------------------------------------------------------------
# Description:
#
#     This script adds a pointer which points to a desired event on the map.
#------------------------------------------------------------------------------
# Compatibility:
#
#     Should be compatible with almost everything.
#------------------------------------------------------------------------------
# Instructions:
#
#     Place this script in a new slot below Scene_Debug and above main.
#   If you're using any input modules and the key you set is from that script,
#   plave this below that input script.
#
#   Use the following call script to set a target event:
#
#         $game_temp.point_towards(EVENT_ID)
#
#   where EVENT_ID is the ID of the event to which the pointer should point.
#
#   To remove the target, use:
#
#         $game_temp.point_towards
#                   or
#         $game_temp.point_towards(nil)
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit for configuration.
#
#  MTP_Pic: Name of the picture file in the "Graphics/Pictures" folder.
#           The pointer should point upwards.
#  MTP_Position: Position of the pointer.
#                 - If it is fixed, use an array of X and Y values
#                   (like this: [X, Y]) if the pointer is static.
#                 - Use nil for placing the pointer above the player.
#  MTP_Key: The key which should be pressed for the pointer to appear.#
#------------------------------------------------------------------------------
# Issues:
#
#     None that I know of.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#    - Fantasist for making this.
#    - Hellfire Dragon for requesting this.
#------------------------------------------------------------------------------
# Notes:
#
#   If you have any problems, suggestions or comments, you can find me at:
#
# - www.chaos-project.com
# - www.quantumcore.forumotion.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** FTSConfig
#==============================================================================
module FTSConfig
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # CONFIG BEGIN
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  MTP_Pic = 'Target_Pointer'
  MTP_Position = nil #[320, 240]
  MTP_Key = Input::A
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # CONFIG END
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
end
#==============================================================================
# ** Game_Temp
#==============================================================================
class Game_Temp
  
  attr_reader :point_target
  
  alias mtp_game_temp_init initialize
  def initialize
    mtp_game_temp_init
    @point_target = nil
  end
  
  def point_towards(val=nil)
    @point_target = val
    $scene.set_target(val) if $scene.is_a?(Scene_Map)
  end
  
end
#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  
  attr_reader :character_sprites
  attr_reader :pointer
  
  alias mtp_spriteset_map_init initialize
  def initialize
    mtp_spriteset_map_init
    @pointer = Pointer.new(self)
    @pointer.z = 5100
  end
  
  alias mtp_spriteset_map_upd update
  def update
    mtp_spriteset_map_upd
    @pointer.update if @pointer != nil
  end
  
  alias mtp_spriteset_map_disp dispose
  def dispose
    mtp_spriteset_map_disp
    @pointer.dispose
  end
  
end
#==============================================================================
# ** Pointer
#==============================================================================
class Pointer < Sprite
  
  attr_reader :target
  attr_accessor :spriteset
  
  def initialize(spriteset)
    super()
    self.visible = false
    self.spriteset = spriteset
    self.target = $game_temp.point_target
    self.bitmap = RPG::Cache.picture(FTSConfig::MTP_Pic)
    if FTSConfig::MTP_Position
      self.x, self.y = FTSConfig::MTP_Position[0], FTSConfig::MTP_Position[1]
    end
  end
  
  def update
    super
    self.visible = @target && Input.press?(FTSConfig::MTP_Key)
    return unless Input.press?(FTSConfig::MTP_Key)
    update_pointing if @target
  end
  
  def update_pointing
    y = ($game_player.screen_y - @target.screen_y).to_f
    x = (@target.screen_x - $game_player.screen_x).to_f
    rad = Math.atan2(y, x) - Math::PI/2
    self.angle = rad * 180 / Math::PI
    unless FTSConfig::MTP_Position
      self.x = $game_player.screen_x
      self.y = $game_player.screen_y - 64
    end
  end
  
  def get_sprite_char(event_id)
    return nil unless $scene.is_a?(Scene_Map)
    self.spriteset.character_sprites.each {|spr_char|
    return spr_char if spr_char.character.id == event_id}
    return nil
  end
  
  def target=(event_id)
    @target = nil if event_id == nil || event_id < 0
    @target = get_sprite_char(event_id)
    @target = @target.character unless @target == nil
    update_pointing if @target
    self.visible = false
  end
  
  def bitmap=(val)
    super(val)
    return if val == nil
    self.ox, self.oy = self.bitmap.width/2, self.bitmap.height/2
  end
  
end
#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map
  
  attr_reader :spriteset
  
  def set_target(event_id)
    @spriteset.pointer.target = event_id
  end
  
end
