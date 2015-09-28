#==============================================================================
# ** Multiple Starting Points
#------------------------------------------------------------------------------
# by Fantasist
# Version 1.1
# 3-July-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First release
#   1.1 - Improved compatibility and fixed off-screen window
#------------------------------------------------------------------------------
# Description:
#
#           When 'New Game' option is selected, a new sub-menu is
#   opened, where the player can chose from different modes. Each
#   mode starts in a different map.
#------------------------------------------------------------------------------
# Compatibility:
#
#           There might be issues with other scripts which modify Scene_Title.
#   This script should be placed ABOVE any other custom scripts if used.
#------------------------------------------------------------------------------
# Instructions:
#
#           Place this script above 'Main'. If you're using any other
#   scripts, all of them should come BELOW this script.
#------------------------------------------------------------------------------
# Configuration:
#
#   Scroll down a bit and you will find the configuration options. They are
#   already set to example values so you understand how to use them.  
#
#   GameModes: GameModes is an array of names of all the gamemodes you use.
#              Name of each mode should be enclosed in quotes ("like this").
#              Different modes should be seperated by commas.
#
#   MapIDs: For each game mode, you should specify the starting map ID here.
#           The order of map IDs match the order of the GameModes defined.
#
#   MapPos: For each mode, you should set the starting point on the map.
#           This is similar to 'Set Start Position' command. To know the
#           coordinates, go to the required map and use the event command
#           'Teleport'. After chosing the start position on the required map,
#           two numbers will be displayed on the top-right corner of the
#           window. These numbers are your starting positions.
#
#   MaxModes: This setting limits the size of the mode selection window.
#             For example, if there are 5 modes and you only want to display
#             3 at a time, you set MaxModes to 3.
#------------------------------------------------------------------------------
# Issues:
#
#    - DO NOT leave the above three arrays empty (none should be []). Just
#      don't use this script if you want to disable it, this won't work with
#      0 modes.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#    Credit me (Fantasist) for making this, IF you want to.
#------------------------------------------------------------------------------
# Notes:
#
#    If you have a problem or suggestion, you can find me at
#    www.chaos-project.com
#    Enjoy ^_^
#==============================================================================

#==============================================================================
# ** Scene_Title
#==============================================================================

class Scene_Title
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Configuration Begin
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  GameModes = ['Map-1', 'Map-2', 'Map-3', 'Map-4', 'Map-5']
  
  MapIDs = [1, 2, 3, 4, 5]
  
  MapPos = [ [5, 10], [7, 10], [9, 10], [11, 10], [13, 10] ]
  
  MaxModes = 3
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Configuration End
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  alias fts_MSP_title_main main
  def main
    if $BTEST
      battle_test
      return
    end
    # Load required stuff for window
    $data_system = load_data('Data/System.rxdata')
    $game_system = Game_System.new
    # Determine window width
    b = Bitmap.new(1, 1)
    w = 0
    for string in GameModes
      tmp = b.text_size(string).width + 32
      w = tmp if tmp > w
    end
    b.dispose
    w = [w, 192].max
    # Make window
    @mode_win = Window_Command.new(w, GameModes)
    @mode_win.height = [32 + MaxModes * 32, 32 + GameModes.size * 32].min
    @mode_win.back_opacity = 160
    @mode_win.x, @mode_win.y = 320 - @mode_win.width / 2, 288
    @mode_win.active = @mode_win.visible = false
    # Execute normal
    fts_MSP_title_main
    # Dispose window
    @mode_win.dispose
  end
  
  def update
    if @command_window.active
      update_command
    elsif @mode_win.active
      update_mode
    end
  end
  
  def update_command
    @command_window.update
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0
        Graphics.freeze
        @command_window.visible = @command_window.active = false
        @mode_win.active = @mode_win.visible = true
        Graphics.transition(5)
      when 1
        command_continue
      when 2
        command_shutdown
      end
    end
  end
  
  def update_mode
    @mode_win.update
    if Input.trigger?(Input::C)
      i = @mode_win.index
      start(MapIDs[i], MapPos[i][0], MapPos[i][1])
    elsif Input.trigger?(Input::B)
      Graphics.freeze
      @mode_win.visible = @mode_win.active = false
      @command_window.active = @command_window.visible = true
      Graphics.transition(5)
    end
  end
  
  def start(id, x, y)
    $game_system.se_play($data_system.decision_se)
    Audio.bgm_stop
    Graphics.frame_count = 0
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    $game_party.setup_starting_members
    $game_map.setup(id)
    $game_player.moveto(x, y)
    $game_player.refresh
    $game_map.autoplay
    $game_map.update
    $scene = Scene_Map.new
  end
  
end