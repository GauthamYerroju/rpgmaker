#=====================================================================================================================
# ** Dynamic Battle Help
#---------------------------------------------------------------------------------------------------------------------
# by Fantasist
# Version 1.0
# 16-Mar-2008
#---------------------------------------------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First public version
#---------------------------------------------------------------------------------------------------------------------
# Description:
#       This script makes better use of the help window during battle. This can be useful
#     when special command windows are used instead of the command window in battle,
#     where text is not displayed (like Icon commands, Ring commands, etc).
#
#     Features:
#      - Displays every selectable command (Fight, Escape, Attack, Skill, Defend, Item)
#      - Can display differently than the actual command ("Use Item" when 'Item' is selected)
#      - Displays actions performed during battle (attacking, defending, skill casting, item using,
#           enemy fleeing and victory)
#      - Instead of just "Attack" or "Arshes attacks", you can chose to display the weapon name
#           ("Attack with Bronze Sword", "Arshes attacks with Bronze Sword"
#           And when no weapon is equipped: "Arshes attacks without weapon)
#      - During battle, the help window can use a solid colored background  instead of
#           the windowskin to make it look professional (the color and opacity are customizable)
#
#---------------------------------------------------------------------------------------------------------------------
# Compatibility:
#     20% chance of problems with other battle scripts.
#   Made to work with Unique Skill Commands addon from Tons and Addons.
#---------------------------------------------------------------------------------------------------------------------
# Installation: Place anywhere above 'Main' and below 'Scene Battle 4'.

# Configuration:

module FTSCFG
#============================================================
# Config Start
#============================================================

  # NOTE: Setting everything with "_Words" to 'nil' will use the default words you set in the database.
  #             Remember that this is the text displayed in the help window, not the command windows.
  
  
  # Party Command text (Fight, Escape window)
  DBH_Fight_Words = 'Engage opponents' # Text to display when 'Fight' is selected
  DBH_Escape_Words = 'Abscond battle'  # Text to display when 'Escape' is selected
  
  # Actor Command text (Attack, Skill, Defend, Item)
  
  DBH_Attack_Weapon = true # Whether to display "with <weapon>" / "without weapon"
  
  DBH_Attack_Words = nil # Text to display when 'Attack' is selected
  DBH_Skill_Words = nil # Text to display when 'Skill' is selected (Unique Skill Commands
                                       #  overrides this setting)
  DBH_Defend_Words = nil # Text to display when 'Defend' is selected
  DBH_Item_Words = nil # Text to display when 'Item' is selected
  
  DBH_Victory_Words = 'Victory!' # Text to display when battle is won
  
  # Help window tweaks
  DBH_Help_Always_Visible = false  # Whether the help window ALWAYS stays visible
  DBH_BG_Mod = false   # Whether a solid background is used instead of the windowskin
  DBH_BG_Color = Color.new(0, 0, 0, 128)  # Color of the solid background (applies for above)
                                                               #  Syntax: Color.new(RED, GREEN, BLUE, OPACITY)
  
#============================================================
# Config End
#============================================================
end
#---------------------------------------------------------------------------------------------------------------------
# Issues: None discovered yet.
#---------------------------------------------------------------------------------------------------------------------
# Credits: Fantasist, for making
# Thanks: Chaos Project (Game) for the inspiration
#---------------------------------------------------------------------------------------------------------------------
# Notes: If you have any problems, questions or suggestions, you can find me here:
#
#  www.quantumcore.forumotion.com
#  www.chaos-project.com/forums
#
#  Enjoy ^_^
#=====================================================================================================================

#=============================================================================
# ** Scene_Battle
#=============================================================================

class Scene_Battle
  
  # Part 1 - This disables the hiding of help window while chosing actions, to prevent flickering.
  
  alias fant_battle_help_mod_start_phase1 start_phase1
  def start_phase1
    @help_window.visible = true
    fant_battle_help_mod_start_phase1
  end
  
  alias fant_battle_help_mod_end_enemy_select end_enemy_select
  def end_enemy_select
    fant_battle_help_mod_end_enemy_select
    @help_window.visible = true
  end
  
  alias fant_battle_help_mod_end_skill_select end_skill_select
  def end_skill_select
    fant_battle_help_mod_end_skill_select
    @help_window.visible = true
  end
  
  alias fant_battle_help_mod_end_item_select end_item_select
  def end_item_select
    fant_battle_help_mod_end_item_select
    @help_window.visible = true
  end
  
  # Part 2 - This updates the help text accordingly when needed.
  
  alias fant_battle_help_mod_update_phase2 update_phase2
  def update_phase2
    txt = case @party_command_window.index
    when 0
      FTSCFG::DBH_Fight_Words ? FTSCFG::DBH_Fight_Words : (@party_command_window.commands[0] rescue 'Fight')
    when 1
      FTSCFG::DBH_Escape_Words ? FTSCFG::DBH_Escape_Words : (@party_command_window.commands[1] rescue 'Escape')
    end
    @help_window.set_text(txt, 1)
    fant_battle_help_mod_update_phase2
  end
  
  alias fant_battle_help_mod_update_phase3_basic_cmd update_phase3_basic_command
  def update_phase3_basic_command
    txt = case @actor_command_window.index
    when 0
      wpn = FTSCFG::DBH_Attack_Weapon ? (" with #{$data_weapons[@active_battler.weapon_id].name}" rescue
      ' without weapon') : ''
      ((FTSCFG::DBH_Attack_Words ? (FTSCFG::DBH_Attack_Words) : (@actor_command_window.commands[0] rescue
      'Attack')) + wpn)
    when 1
      if $tons_version && $game_system.UNIQUE_SKILL_COMMANDS
        (@actor_command_window.commands[1] rescue (FTSCFG::DBH_Skill_Words ? FTSCFG::DBH_Skill_Words : 'Skill'))
      else
        (FTSCFG::DBH_Skill_Words ? FTSCFG::DBH_Skill_Words : (@actor_command_window.commands[1] rescue 'Skill'))
      end
    when 2
      FTSCFG::DBH_Defend_Words ? FTSCFG::DBH_Defend_Words : (@actor_command_window.commands[2] rescue 'Defend')
    when 3
      FTSCFG::DBH_Item_Words ? FTSCFG::DBH_Item_Words : (@actor_command_window.commands[3] rescue 'Item')
    end
    @help_window.set_text(txt, 1)
    fant_battle_help_mod_update_phase3_basic_cmd
  end
  
  alias fant_battle_help_mod_start_phase5 start_phase5
  def start_phase5
    @help_window.set_text(FTSCFG::DBH_Victory_Words, 1)
    fant_battle_help_mod_start_phase5
  end
  
  alias fant_battle_help_mod_make_basic_action_result make_basic_action_result
  def make_basic_action_result
    fant_battle_help_mod_make_basic_action_result
    if @active_battler.current_action.basic == 0
      txt = "#{@active_battler.name} attacks" + ((@active_battler.is_a?(Game_Enemy) ||
      !FTSCFG::DBH_Attack_Weapon) ? '' :
      (" with #{$data_weapons[@active_battler.weapon_id].name}" rescue ' without weapon'))
      @help_window.set_text(txt, 1)
    elsif @active_battler.current_action.basic == 1
      @help_window.set_text("#{@active_battler.name} defends", 1)
    elsif @active_battler.is_a?(Game_Enemy) && @active_battler.current_action.basic == 2
      @help_window.set_text("#{@active_battler.name} fled", 1)
    end
  end
  
  alias fant_battle_help_mod_make_skill_action_result make_skill_action_result
  def make_skill_action_result
    fant_battle_help_mod_make_skill_action_result
    @help_window.set_text("#{@active_battler.name} performs #{@skill.name}", 1)
  end
  
  alias fant_battle_help_mod_make_item_action_result make_item_action_result
  def make_item_action_result
    fant_battle_help_mod_make_item_action_result
    @help_window.set_text("#{@active_battler.name} uses #{@item.name}", 1)
  end
  
end

#=============================================================================
# ** Window_Help
#=============================================================================

class Window_Help
  
  alias fant_battle_help_mod_help_win_init initialize
  def initialize
    fant_battle_help_mod_help_win_init
    if $scene.is_a?(Scene_Battle) && FTSCFG::DBH_BG_Mod
      self.y -= 8
      self.opacity = 0
      bmp = Bitmap.new(640-16, 32)
      bmp.fill_rect(0, 0, 640-16, 32, FTSCFG::DBH_BG_Color)
      @bg = Sprite.new
      @bg.x, @bg.y, @bg.z = self.x + 8, self.y + 16, self.z + 1
      @bg.bitmap = bmp
    end
  end
  
  def visible=(val)
    super(val)
    if $scene.is_a?(Scene_Battle) && !FTSCFG::DBH_BG_Mod
      val = FTSCFG::DBH_Help_Always_Visible unless val
      super(val)
    end
    if @bg
      val = FTSCFG::DBH_Help_Always_Visible unless val
      @bg.visible = val
    end
  end
  
  alias fant_battle_help_mod_help_win_dispose dispose
  def dispose
    fant_battle_help_mod_help_win_dispose
    if @bg != nil
      @bg.bitmap.dispose
      @bg.dispose
    end
  end
  
end

#=============================================================================
# ** Window_Command
#=============================================================================

class Window_Command
  attr_accessor :commands
end

#=============================================================================
# ** Window_PartyCommand
#=============================================================================
class Window_PartyCommand
  
  alias fant_battle_help_mod_win_party_init initialize
  def initialize
    fant_battle_help_mod_win_party_init
    self.y = 64
  end
  
end