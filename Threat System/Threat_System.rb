#==============================================================================
# ** Threat System
#------------------------------------------------------------------------------
# by Fantasist
# Version: 1.0
# Date: 13-July-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version
#------------------------------------------------------------------------------
# Description:
#
#     During battle, enemies will choose their targets based on their "threat"
#   rather than randomly. The threat for an actor changes depending on what they
#   do. For example, attacking raises threat and defending decreases threat.
#------------------------------------------------------------------------------
# Compatibility:
#
#   Might be incompatible with other battle systems or battle addons.
#------------------------------------------------------------------------------
# Instructions:
#
#    Place this script anywhere above "Main" and below "Scene_Debug".
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit and you'll see the configuration.
#
#   ATTACK_THREAT: Threat to increase when actor attacks
#   DEFEND_THREAT: Threat to decrease when actor defends
#   THREAT_CHANCE: The chance of enemies attacking based on threat
#  THREAT_DISPLAY: Display players' threats besides their name
#   THREAT_WINDOW: Whether to enable or disable threat window
#                  To enable it, set it to "true". If you want to set it's
#                  position and width, you can also set it to an array with
#                  it's X position, Y position and width (eg: [0, 64, 160]).
#
#   Skill Threat Configuration:
#
#     Look for "SKILL THREAT CONFIG BEGIN" and follow the example.
#     In the given example:
#
#               when 57 then [10, -2]
#
#     the skill 57 (Cross Cut) increases user's threat by 10 and decreases the
#     rest of the party's threat by 2.
#
#   Item Threat Configuration:
#
#     Works exactly the same as skill threat configuration.
#------------------------------------------------------------------------------
# Credits:
#
#   Fantasist, for making this script
#   KCMike20, for requesting this script
#
# Thanks:
#
#   Blizzard, for helping me
#   winkio, for helping me
#   Jackolas, for pointing out a bug
#------------------------------------------------------------------------------
# Notes:
#
#   If you have any problems, suggestions or comments, you can find me at:
#
#     forum.chaos-project.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** ThreatConfig module
#------------------------------------------------------------------------------
#  Module for settings and configuration of the Threat system.
#==============================================================================

module ThreatConfig
  #--------------------------------------------------------------------------
  # * Config
  #--------------------------------------------------------------------------
  ATTACK_THREAT = 1 # Threat to increase when actor attacks
  DEFEND_THREAT = 1 # Threat to decrease when actor defends
  THREAT_CHANCE = 100 # The chance of enemies attacking based on threat
  THREAT_DISPLAY = true # Display player's threat besides their name
  THREAT_WINDOW = [480, 64, 160] # Whether to enable or disable threat window
  #--------------------------------------------------------------------------
  # * Configure skill threats
  #--------------------------------------------------------------------------
  def self.get_skill_threat(skill_id)
    threat = case skill_id
    #========================================================================
    # SKILL THREAT CONFIG BEGIN
    #========================================================================
    when 57 then [5, -1] # Cross Cut
    when 61 then [5, -1] # Leg Sweep
    when 7 then [5, 0]   # Fire
    # when skill_ID then [ user_threat, party_threat ]
    #========================================================================
    # SKILL THREAT CONFIG END
    #========================================================================
    else false
    end
    return threat
  end
  #--------------------------------------------------------------------------
  # * Configure item threats
  #--------------------------------------------------------------------------
  def self.get_item_threat(item_id)
    threat = case item_id
    #========================================================================
    # ITEM THREAT CONFIG BEGIN
    #========================================================================
    when 1 then [2, -5] # Potion
    # when item_ID then [ user_threat, party_threat ]
    #========================================================================
    # ITEM THREAT CONFIG END
    #========================================================================
    else false
    end
    return threat
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  Added the threat attribute.
#==============================================================================

class Game_Actor
  #--------------------------------------------------------------------------
  # * Initialize threat attribute
  #--------------------------------------------------------------------------
  alias game_actor_threat_setup setup
  def setup(actor_id)
    @threat = 0
    game_actor_threat_setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # * Get the threat attribute
  #--------------------------------------------------------------------------
  attr_reader :threat
  #--------------------------------------------------------------------------
  # * Set the threat attribute
  #--------------------------------------------------------------------------
  def threat=(val)
    val = 0 if val < 0
    @threat = val
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Modified random actor selection to select by threat.
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # * Choose actor by threat
  #--------------------------------------------------------------------------
  alias choose_actor_threat_orig random_target_actor
  def random_target_actor(hp0 = false)
    if rand(100) >= ThreatConfig::THREAT_CHANCE
      return choose_actor_threat_orig(hp0)
    else
      return threat_target_actor(hp0)
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate threat and choose actor
  #--------------------------------------------------------------------------
  def threat_target_actor(hp0=false)
    # Collect valid actors
    targets = []
    for actor in @actors
      next unless (!hp0 && actor.exist?) || (hp0 && actor.hp0?)
      targets.push(actor)
    end
    # Get actors with maximum threat
    targets.sort! {|a, b| b.threat - a.threat}
    targets = targets.find_all {|a| a.threat == targets[0].threat}
    # Choose random
    target = targets[rand(targets.size)]
    return target
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  Added attack and skill threat handling.
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Attack Threat
  #--------------------------------------------------------------------------
  alias attack_effect_threat attack_effect
  def attack_effect(attacker)
    attacker.threat += ThreatConfig::ATTACK_THREAT if attacker.is_a?(Game_Actor)
    attack_effect_threat(attacker)
  end
  #--------------------------------------------------------------------------
  # * Skill Threat
  #--------------------------------------------------------------------------
  alias skill_effect_threat skill_effect
  def skill_effect(user, skill)
    threat = user.is_a?(Game_Actor) && ThreatConfig.get_skill_threat(skill.id)
    if threat
      user_threat, party_threat = threat[0], threat[1]
      for actor in $game_party.actors
        threat_plus = actor.id == user.id ? user_threat : party_threat
        actor.threat += threat_plus
      end
    end
    skill_effect_threat(user, skill)
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  Added defend and item threat handling and realtime target selection.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Defend Threat
  #--------------------------------------------------------------------------
  alias basic_action_threat_result make_basic_action_result
  def make_basic_action_result
    if @active_battler.current_action.basic == 1 && @active_battler.is_a?(Game_Actor)
      @active_battler.threat -= ThreatConfig::DEFEND_THREAT
    end
    basic_action_threat_result
  end
  #--------------------------------------------------------------------------
  # * Item Threat
  #--------------------------------------------------------------------------
  alias item_action_threat_result make_item_action_result
  def make_item_action_result
    item_action_threat_result
    threat = @active_battler.is_a?(Game_Actor) && ThreatConfig.get_item_threat(@item.id)
    if threat
      user_threat, party_threat = threat[0], threat[1]
      for actor in $game_party.actors
        threat_plus = actor.id == @active_battler.id ? user_threat : party_threat
        actor.threat += threat_plus
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Choose target actor in realtime
  #--------------------------------------------------------------------------
  alias update_phase4_step2_choose_actor_realtime update_phase4_step2
  def update_phase4_step2
    @active_battler.make_action if @active_battler.is_a?(Game_Enemy)
    update_phase4_step2_choose_actor_realtime
  end
  #--------------------------------------------------------------------------
  # * Clear threats before battle
  #--------------------------------------------------------------------------
  alias clear_threats_start_phase1 start_phase1
  def start_phase1
    clear_threats_start_phase1
    $game_party.actors.each {|actor| actor.threat = 0}
  end
end

if ThreatConfig::THREAT_DISPLAY
#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  Modded to show threat beside actor's name.
#==============================================================================

class Window_BattleStatus
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  alias threat_display_refresh refresh
  def refresh
    threat_display_refresh
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      next if actor.threat == 0
      actor_x = i * 160 + 4
      actor_x += self.contents.text_size(actor.name).width + 4
      self.contents.draw_text(actor_x, 0, 160, 32, "(#{actor.threat})")
    end
  end
end
end

if ThreatConfig::THREAT_WINDOW
#==============================================================================
# ** Window_Threat
#------------------------------------------------------------------------------
#  This window displays the threats of actors in the party.
#==============================================================================

class Window_Threat < Window_Base
  H = 18
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    a = ThreatConfig::THREAT_WINDOW
    if a.is_a?(Array)
      x, y, w = a[0], a[1], a[2]
    else
      x, y, w = 0, 64, 160
    end
    super(x, y, w, 32 + H + $game_party.actors.size * H)
    @threats = []
    $game_party.actors.each {|a| @threats.push(a.threat)}
    self.contents = Bitmap.new(w-32, self.height-32)
    self.contents.font.size = H
    self.contents.font.bold = H <= 22
    self.opacity = 160
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.draw_text(0, 0, self.width-32, H, 'Threats', 1)
    $game_party.actors.each_with_index {|a, i| y_off = H
    self.contents.draw_text(0, y_off + i*H, self.width-32, H, a.name)
    self.contents.draw_text(0, y_off + i*H, self.width-32, H, @threats[i].to_s, 2)}
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    flag = false
    $game_party.actors.each_with_index {|a, i|
    @threats[i] = a.threat if a.threat != @threats[i]
    flag = true}
    refresh if flag
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  Modded to handle threat window.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  alias threat_win_init main
  def main
    @threat_win = Window_Threat.new
    threat_win_init
    @threat_win.dispose
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  alias threat_win_upd update
  def update
    @threat_win.update
    threat_win_upd
  end
end
end