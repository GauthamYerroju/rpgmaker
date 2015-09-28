#==============================================================================
# Enhanced Battle Cursors v2.1 beta
# by Fantasist
#==============================================================================
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# - code reviewed, optimized, integrated into Tons of Add-ons, freed from
#   potential bugs and beta tested by Blizzard
# - this add-on is part of Tons of Add-ons with full permission of the original
#   author(s)
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#------------------------------------------------------------------------------
# * Config (these can't be changed in-game)
#------------------------------------------------------------------------------
# Position
#       Set the position of the cursor
#
# 1) Monster_Height: The height of the cursor from the monster graphic's base.
# 2) Actor_Height: The height of the cursor from the actor graphic's base.
MONSTER_OFFSET = 0
ACTOR_OFFSET = 0
#------------------------------------------------------------------------------
# Movement Type Config
#       Configuration for the movement types used
#
# 1) Phase_Range: The distance the cursor moves away from the height while
#    phasing.
# 2) Zoom_Factor: The amount the cursor zooms in and out. Recommended range is
#    from 0 to 1, refrain from using more than 2 digits after decimal.
# 3) EBC_Type: This is the configuration of animation types
#        [Anim or not(true/false), movement type, transition type]
#      available movement types   -> phase, zoom, spin, spin2
#      available transition types -> trans, default
#    If you are using animations (first parameter is true) then use numbers
#    instead of movement and transition types to determine the animation IDs
#    of the animations used. The first is the actor, the second is the enemy
#    animation ID.
PHASE_RANGE = 16
ZOOM_FACTOR = 0.2
EBC_TYPE = [false, 'phase', 'trans']
# EBC_type can be changed ingame, refer to $game_system.battle_cursor and
# set the new values. This change is being saved with the save file.
#==============================================================================

#==============================================================================
# ** Game System
#==============================================================================

class Game_System
  
  attr_accessor :battle_cursor
  
  alias init_battle_cursor initialize
  def initialize
    init_battle_cursor
    @battle_cursor = EBC_TYPE
  end  
  
end

#==============================================================================
# ** Arrow_Base
#==============================================================================

class Arrow_Base < RPG::Sprite

  attr_reader   :index
  attr_reader   :help_window
    
  def initialize(viewport)
    super
    if $game_system.battle_cursor[0]
      tmp, @battler = $game_system.battle_cursor, nil
      @actor_cursor = (tmp[1].is_a?(Numeric) ? tmp[1] : 98)
      @enemy_cursor = (tmp[2].is_a?(Numeric) ? tmp[2] : 99)
    else
      # Main Sprite initialization
      self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
      self.src_rect.set(128, 96, 32, 32)
      self.ox, self.oy, self.z = 16, 64, 2501
      # Sub-sprite initialization
      if animtype('trans')
        @sp2 = Sprite.new(viewport)
        @sp2.bitmap = self.bitmap
        @sp2.src_rect.set(160, 96, 32, 32)
        @sp2.ox, @sp2.oy, @sp2.z = self.ox, self.oy, self.z-1
      end
      # Variable initialization
      @rad = 0 if animtype('trans') || ['phase', 'zoom', 'spin2'].any? {|i| movetype(i)}
      @deg = 0 if movetype('spin')
      @battler = nil
      @blink_count = 0 if animtype('default')
    end
    @y, @index, @help_window = 0, 0, nil
    update
  end
  
  def movetype(type)
    return ($game_system.battle_cursor[1] == type)
  end
  
  def animtype(type)
    return ($game_system.battle_cursor[2] == type)
  end
  
  def index=(index)
    @index = index
    update
  end

  def help_window=(help_window)
    @help_window = help_window
    # Update help text (update_help is defined by the subclasses)
    update_help if @help_window != nil
  end

  def update
    super
    if $game_system.battle_cursor[0]
      # Update animation
      id = self.is_a?(Arrow_Actor) ? @actor_cursor : @enemy_cursor
      loop_animation($data_animations[id])
    else
      if @rad
        # Cycle @rad from 0 to 2 Pi
        if @rad < 2 * Math::PI
          @rad += Math::PI/(movetype('spin2') ? 30 : 10)
        else
          @rad = 0
        end
      end
      # Animations
      trans if animtype('trans')
      default if animtype('default')
      # Movement Types
      phase if movetype('phase')
      spin if movetype('spin')
      spin2 if movetype('spin2')
      zoom if movetype('zoom')
    end
    # Update Help Window
    update_help if @help_window != nil
  end

  def dispose
    @sp2.dispose unless @sp2 == nil || @sp2.disposed?
    super
  end

  #--------------------------------------------------------------------------
  # * Cursor Animations
  #--------------------------------------------------------------------------
  def trans
    self.opacity = (Math.sin(@rad)*255).round
  end
  
  def default
    @blink_count = (@blink_count + 1) % 8
    self.src_rect.set((@blink_count < 4 ? 128 : 160), 96, 32, 32)
  end

  #--------------------------------------------------------------------------
  # * Cursor Movements
  #--------------------------------------------------------------------------
  def phase
    @y = ((Math.sin(@rad))*PHASE_RANGE).round
  end

  def spin
    # Cycle @deg from 0 to 360
    self.angle = @deg = (@deg + 18) % 360
    @sp2.angle = @deg if @sp2
  end

  def spin2
    self.angle = (Math.sin(@rad)*360).round
    @sp2.angle = self.angle if @sp2
  end
  
  def zoom
    self.zoom_x = self.zoom_y = 1 + Math.sin(@rad)*ZOOM_FACTOR
    @sp2.zoom_x = self.zoom_x if @sp2
  end
 
end

#==============================================================================
# ** Arrow_Enemy
#==============================================================================

class Arrow_Enemy < Arrow_Base
    
  def enemy
    return $game_troop.enemies[@index]
  end

  def update
    super
    # Skip if indicating a nonexistant enemy
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index = (@index + 1) % $game_troop.enemies.size
    end
    # Cursor right
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index = (@index + 1) % $game_troop.enemies.size
        break if self.enemy.exist?
      end
    # Cursor left
    elsif Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index = (@index + $game_troop.enemies.size - 1) % $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # Set sprite coordinates
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
      self.y += -@y - MONSTER_OFFSET
      @sp2.x, @sp2.y = self.x, self.y if @sp2
    end
  end

  def update_help
    if $game_system.ENEMY_STATUS
      # Display enemy name and state in the help window
      @help_window.set_actor(self.enemy)
    else
      @help_window.set_enemy(self.enemy)
    end
  end
  
end

#==============================================================================
# ** Arrow_Actor
#==============================================================================

class Arrow_Actor < Arrow_Base
  
  def actor
    return $game_party.actors[@index]
  end
  
  def update
    super
    # Cursor right
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index = (@index + 1) % $game_party.actors.size
    # Cursor left
    elsif Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index = (@index + $game_party.actors.size - 1) % $game_party.actors.size
    end
    # Set sprite coordinates
    if self.actor != nil
      if $game_system.CENTER_BATTLER
        self.x = case $game_party.actors.size
        when 1 then 240 + self.actor.screen_x
        when 2 then 2 * self.actor.screen_x
        when 3 then 80 + self.actor.screen_x
        when 4 then self.actor.screen_x
        end
      else
        self.x = self.actor.screen_x
      end
      self.y = self.actor.screen_y
      self.y += -@y - ACTOR_OFFSET
      @sp2.x, @sp2.y = self.x, self.y if @sp2
    end
  end
  
  def update_help
    # Display actor status in help window
    @help_window.set_actor(self.actor)
  end
  
end