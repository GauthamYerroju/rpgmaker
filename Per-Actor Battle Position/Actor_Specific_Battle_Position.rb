#==============================================================================
# ** Per-Actor Battle Position
#------------------------------------------------------------------------------
# by Fantasist
# Version: 1.0
# Date: 16-Mar-2010
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version
#------------------------------------------------------------------------------
# Description:
#
#     This script allows you a finer degree of control over the position during
#   battle ("Front", "Middle", "Rear"). You normally set positions to actor
#   classes and not actors themselves. With this script, you can decide the
#   battle positions of individual actors. You can also change positions in-game.
#     By default, there are only 3 positions: Front, Middle and Rear. With this
#   script, you can add as many positions as you want.
#------------------------------------------------------------------------------
# Compatibility:
#
#    - Aliased Game_Actor::setup(actor_id)
#    - Rewritten Game_Party::random_target_actor(hp0)
#
#   Not tested extensively, but should work with most other scripts.
#------------------------------------------------------------------------------
# Instructions:
#
#   Place this script below "Game_Party".
#     Optionally, I suggest you configure the battle position in the database
#   anyway, despite using this script. This is because if an actor's position is
#   not configured, this script used the database setting for the actor's class.
#
#   To change an actor's position in-game, use the following script call:
#
#       $game_actors[<ACTOR_ID>].position = <POSITION>
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit for the configuration.
#
#   1. MAX_POSITION: The number of positions you will be using (Default: 3)
#
#   2. Look for:
#   #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#   # * CONFIG START
#   #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#   Then add more lines as needed. The format is:
#
#         when <ACTOR_ID> then <POSITION>
#------------------------------------------------------------------------------
# Regarding the value of Position:
#
#   POSITION takes the values from 1 to MAX_POSITION (Default: 1, 2 or 3)
#   The larger the number, the farther the position, so 1 is front and
#   MAX_POSITION if rear. During the config or setting position in-game, if you
#   set it to 0, the database position will be used. Every other out of range
#   value (like -1, -23, 100, 4, 5 for the default) will be corrected.
#------------------------------------------------------------------------------
# Issues:
#
#   None known.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Credits: Fantasist for making this.
#   Thanks: Zydragon and MeVII for requesting.
#------------------------------------------------------------------------------
# Notes:
#
#     If you have any questions, suggestions or comments, you can
#   find me (Fantasist) in the forums at:
#
#    - www.chaos-project.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** Fantasist's Configuration Module
#==============================================================================
module FTSConfig
  
  MAX_POSITION = 3 # Maximum number of positions
  
  def self.per_actor_position(actor_id)
    position = case actor_id
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # * CONFIG START
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # when <actor_id> then <position>
    when 1 then 1
    when 2 then 1
    when 7 then 3
    when 8 then 2
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # * CONFIG END
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    else
      0
    end
    return position
  end
end
#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor
  attr_reader :position
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  alias per_actor_pos_actor_setup setup
  def setup(actor_id)
    # Get actor position from config
    self.position = FTSConfig.per_actor_position(actor_id)
    per_actor_pos_actor_setup(actor_id) # Call everything else
  end
  #--------------------------------------------------------------------------
  # * Position=
  #--------------------------------------------------------------------------
  def position=(val)
    # If not configured, set default
    if val == 0
      actor = $data_actors[actor_id]
      actor_class = $data_classes[actor.class_id]
      # Correct the default (poaition starts with 0) to comply with
      # the new convention (starts with 1)
      val = $data_classes[@class_id].position + 1
    end
    # Correction
    val = FTSConfig::MAX_POSITION if val > FTSConfig::MAX_POSITION
    val = 1 if val < 0
    @position = val
  end
end
#==============================================================================
# ** Game_Party
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # * Random Selection of Target Actor
  #--------------------------------------------------------------------------
  def random_target_actor(hp0 = false)
    roulette = []
    actors.each {|actor|
    next unless (!hp0 && actor.exist?) || (hp0 && actor.hp0?)
    position = actor.position
    # Larger the number (n), more to the front
    n = FTSConfig::MAX_POSITION + 2 - position
    n.times {roulette.push(actor)}
    }
    return nil if roulette.size == 0
    return roulette[rand(roulette.size)]
  end
end