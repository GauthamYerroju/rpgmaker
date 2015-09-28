#==============================================================================
# ** Actor-specific Item Usability
#------------------------------------------------------------------------------
# by Fantasist
# Version 1.0
# 21-Nov-2008
#------------------------------------------------------------------------------
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# - code reviewed, optimized, integrated into Tons of Add-ons, freed from
#   potential bugs and beta tested by Blizzard
# - this add-on is part of Tons of Add-ons with full permission of the original
#   author(s)
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#------------------------------------------------------------------------------
# Version History:
#
#   v1.0 - First release
#------------------------------------------------------------------------------
# Description:
#
#     This scriptlet enables you to define which items can't be consumed by
#   each actor. For example, actor ID 4 (who maybe a robot) cannot use
#   "Potion". Similarly, actor ID 1 (Arshes) cannot consume "Recharge Cell".
#------------------------------------------------------------------------------
# Compatibility:
#
#    - Should be compatible with most scripts.
#------------------------------------------------------------------------------
# Instructions:
#
#   Place this below "Scene_Debug" and above "Main"
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down and you'll find the configuration.
#
#   The main syntax is:
#
#     when ACTOR_ID then [IDs of all items which this actor CAN'T use]
#
#   Examples:
#
#     when 1 then [1, 2] # Arshes can't use "Potion" and "High Potion".
#
#     when 7 then [10, 11, 12] # Gloria can't use "Full Tonic", "Antidote" and
#                              # "Dispell Herb".
#
#   NOTE: For all actors without a configuration, items are usable by default.
#         So if Basil can use all items, then you don't need to configure for
#         ID 2.
#------------------------------------------------------------------------------
# Issues:
#
#     None that I know of.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Credits: Fantasist, for making this
#   Thanks: Spoofus, for requesting this
#------------------------------------------------------------------------------
# Notes:
#
#   If you have any problems or suggestions, you can find me at:
#
#    - www.chaos-project.com
#    - www.quantumcore.forumotion.com
#
#   Enjoy ^_^
#============================================================================

#==============================================================================
# * module FTSConfigs
#==============================================================================

module FTSConfigs
  
  def self.item_can_consume?(actor_id, item_id)
    nonusable_item_ids = case actor_id
    #==========================================================================
    # * CONFIG BEGIN
    #==========================================================================
    when 1 then [1]
    when 2 then [2]
    # when ACTOR_ID then [IDs of all items which this actor CAN'T use]
    #==========================================================================
    # * CONFIG END
    #==========================================================================
    else
      []
    end
    return !nonusable_item_ids.include?(item_id)
  end
  
end

#==============================================================================
# * Game_Battler
#==============================================================================

class Game_Battler
  
  alias item_effect_actoritem_override item_effect
  def item_effect(item)
    if $game_system.ACTOR_ITEMS && self.is_a?(Game_Actor)
      return false if !FTSConfigs.item_can_consume?(self.id, item.id)
    end
    return item_effect_actoritem_override(item)
  end
  
end
