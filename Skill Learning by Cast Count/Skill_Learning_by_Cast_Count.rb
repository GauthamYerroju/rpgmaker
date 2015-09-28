#============================================================================
# ** Skill Learning by Cast Count (SLCC)
#----------------------------------------------------------------------------------------
# by Fantasist
# Version 0.91
# 28-Aug-2008
#----------------------------------------------------------------------------------------
# Version History:
#
#   0.9 - Beta
#   0.91 - updated documentation and SKILL_LEARN_SE can be on/off
#----------------------------------------------------------------------------------------
# Description:
#
#      This script allows actors to learn new skills after using one of their 
#    existing skills a certain number of times, similar to the "Tales of" Games. 
#    That's the basic concept, here are a few examples:
#
#  1 - If you cast "Heal" 20 times, you learn "Greater Heal".
#  2 - If you cast "Heal" 25 times, you learn "Greater Heal". Casting "Heal" 50 
#       times (or 25 more times after that) would result in learning "Mass Heal".
#  3 - If you cast "Heal" 20 times, both "Greater Heal" AND "Mass Heal" will be 
#       learned.
#  4 - If you cast "Heal" 10 times and "Raise" 5 times, you learn "Mass Heal".
#  5 - You can set different conditions for every actor.
#
# Therefore, what this script enables:
#
#   - Learning 1 or more skills by casting existing skills at any time.
#   - Setup everything differently for each actor
#----------------------------------------------------------------------------------------
# Instructions/Configuration:
#
#     Place this script above "Main".
#
#     The configuration might look tricky, but if you follow the instructions,
#   it's easy. It's just like applying a formula to get a result. Note that each
#   config has to be done for each actor seperately. The main format will be
#   something like this:
#
#   when ACTOR_ID
#     CONFIG_FOR_ACTOR
#   when ACTOR_ID
#     CONFIG_FOR_ACTOR
#   end
#
#   The config mainly consists of two parts:
#      - Config of skill(s) learned by casting ONE skill (1, 2, 3 in description)
#      - Config of skill(s) learned by casting MULTIPLE skills (4 in description)
#
#   PART 1:
#
#     when SKILL_ID then [[x, ID1], [y, ID2, ID3, ID4....], .....]
#
#   The above line means that when SKILL_ID is cast...
#     x times, then skill with ID1 is learned  
#     y times, then skills with IDs ID1, ID2, ID3, ID4... are learned
#
#   PART 2:
#
#   when ACTOR_ID
#       [
#       [ [1, 1], [57, 1], [6, 1], [10] ] ,
#       [ [1, 2], [6, 1], [10, 1], [14, 15, 16...] ]
#       ]
#
#   The above lines mean that when ACTOR_ID:
#      - When skill with ID 1 is used once, 57 is used once, and 6 is used once,
#         then ACTOR_ID learns Skill ID 10. This is all ONE CONDITION.
#      - When skill with ID 1 is used twice, 6 is used once, and 10 is used once,
#         then skills 14, 15, 16... are learned.
#
#     Observe how for every condition the list of skills that will be
#     learned should be at the end, while in the beginning it's the skills that
#     need to be casted a certain number of times, being 
#     ([skill_id, cast_number_of_times]).
#
#     Add as many conditions as you want in new lines between the top and
#   bottom "[" and "]", but remember to put the comma after every condition
#   except the last one.
#
#     Lastly, newly learned skills are displayed in popups after the battle is
#   complete. If you want an SE to play with the popups, change the constant
#   SKILL_LEARN_SE. The format is:
#
#       SKILL_LEARN_SE = RPG::AudioFile.new('SE Filename', volume, pitch)
#
#     If you want to disable the sound, set to "nil". It would look like this:
#
#             SKILL_LEARN_SE = nil
#     
#----------------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Credits: Fantasist for making this.
#   Thanks: Viviatus for requesting this.
#               Starrodkirby86 for helping me explain the config.
#----------------------------------------------------------------------------------------
# Notes:
#
#   THIS IS NOT A PUBLIC VERSION!!!
#   If you have any problems or suggestions, you can find me by the name
#   'Fantasist' at:
#
#   www.quantumcore.forumotion.com
#   www.chaos-project.com
#
#   Enjoy! ^_^
#============================================================================

#==============================================================================
# FTS (module)
#==============================================================================

module FTS
  
  # RPG::AudioFile.new('SE Filename', volume, pitch)
  # for disabling, set to "nil" (SKILL_LEARN_SE = nil)
  SKILL_LEARN_SE = RPG::AudioFile.new('056-Right02', 100, 100)
  
  module_function
  
  def learn_new_skills?(actor_id, skill_id)
    case actor_id
    #================================
    # Config PART-1 Begin
    #================================
    when 1 # when actor_id
      a = case skill_id
      when 1 then [[1, 6], [2, 7], [5, 10], [12, 13, 14, 15, 16], [3, 34, 35]]
      else false
      end
    #----------------------------------------------------------------
    # Actor Seperator
    #----------------------------------------------------------------
    when 7 # when actor_id
      a = case skill_id
      when 1 then [[2, 8, 9]]
      else false
      end
    #================================
    # Config PART-1 End
    #================================
    end
    return a
  end
  
  def learn_from_many?(actor_id)
    a = case actor_id
    #================================
    # Config PART-2 Begin
    #================================
    when 1 # when actor_id
      [
      [[1, 1], [57, 1], [6, 1], [10, 11, 12, 13]],
      [[1, 2], [6, 1], [10, 1], [14, 15, 16, 17]]
      ]
    #----------------------------------------------------------------
    # Actor Seperator
    #----------------------------------------------------------------
    when 7 # when actor_id
      [
      [[1, 2], [8, 1], [9, 1], [14, 15, 16, 17]]
      ]
    #================================
    # Config PART-2 End
    #================================
    else
      false
    end
    return a
  end
  
end

#==============================================================================
# Game_Actor
#==============================================================================

class Game_Actor
  
  attr_accessor :skill_learns, :skill_uses
  
  alias fts_skill_learning_game_actor_setup setup
  def setup(actor_id)
    fts_skill_learning_game_actor_setup(actor_id)
    skill_list = load_data('Data/Skills.rxdata')
    @skill_uses = Array.new(skill_list.size + 1, 0)
    @skill_uses[0], @skill_learns, skill_list = id, [], nil
  end
  
end

#==============================================================================
# Scene_Battle
#==============================================================================

class Scene_Battle
  
  alias fts_skill_learning_scene_battle_skill_action_result make_skill_action_result
  def make_skill_action_result
    battler = @active_battler
    @skill = $data_skills[battler.current_action.skill_id]
    if battler.is_a?(Game_Actor) && battler.skill_can_use?(@skill.id)
      battler.skill_uses[@skill.id] += 1
      conditions_list = FTS::learn_new_skills?(battler.id, @skill.id)
      if conditions_list
        conditions_list.each {|times_list| times = times_list.shift
        if battler.skill_uses[@skill.id] == times
        times_list.each {|skill_id| battler.skill_learns.push(skill_id)}
        end}
      end
      conditions_list = FTS::learn_from_many?(battler.id)
      if conditions_list
        conditions_list.each {|conditions| result, val = conditions.pop, true
        conditions.each {|id_times| id, times = id_times[0], id_times[1]
        val = false unless battler.skill_uses[id] >= times}
        battler.skill_learns |= result if val}
      end
      battler.skill_learns -= battler.skills
    end
    fts_skill_learning_scene_battle_skill_action_result
  end
  
  alias fts_skill_learning_scene_battle_init5 start_phase5
  def start_phase5
    fts_skill_learning_scene_battle_init5
    @new_skills = []
    $game_party.actors.each_with_index {|actor, i| actor.skill_learns.each {|id|
    @new_skills.push([i, id])}
    actor.skill_learns = []}
    @learn_skill_count = @new_skills.size
  end
  
  alias fts_skill_learning_scene_battle_upd5 update_phase5
  def update_phase5
    if @learn_skill_count > 0
      if @learn_skill_count == @new_skills.size
        a = @new_skills.shift
        actor = $game_party.actors[a[0]]
        actor.learn_skill(a[1])
        actor.damage = "+ #{$data_skills[a[1]].name}!"
        $game_system.se_play(FTS::SKILL_LEARN_SE) if FTS::SKILL_LEARN_SE
        actor.damage_pop = true
      end
      @learn_skill_count -= 1
    end
    fts_skill_learning_scene_battle_upd5
  end
  
end
