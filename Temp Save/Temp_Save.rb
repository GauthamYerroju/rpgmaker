#==============================================================================
# ** Temp Save
#------------------------------------------------------------------------------
# by Fantasist
# Version: 2.1
# Date: 05-July-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version for the default title and file scenes
#   1.1 - Improved coding
#   2.0 - Complete overhaul, greatly increased compatibility
#   2.1 - Removed obselete option, added prompt disable and fixed some bugs
#------------------------------------------------------------------------------
# Description:
#
#     With this script, the 'Save' option in the menu will do a quick save and
#   take you to the title screen. The next time you load, the quick save is
#   loaded instead of letting the playwer choose from the save files. Once the
#   quick save file is loaded, it is deleted.
#------------------------------------------------------------------------------
# Compatibility:
#
#     From version 2.0, it should be compatible with almost anything, including
#   exotic save systems, save scenes and even encryption systems.
#
#   For scripters: There is nothing like absolute compatibility, so this still
#   has it's limitations:
#    - The quick save procedure is only activated when Scene_Save is called
#      from Scene_Menu. You can change that by tinkering with
#      "@temp_save_active" in "Scene_Save" -> "initialize".
#    - This script assumes that you're using the Scene_File class for the
#      saving and loading.
#==============================================================================
# Instructions:
#
#    - Place this script anywhere above "Main" and below "Scene_Load".
#    - In Scene_Title, find the following lines or similar:
#
#          @continue_enabled = false
#          for i in 0..3
#            if FileTest.exist?("Save#{i+1}.rxdata")
#              @continue_enabled = true
#            end
#          end
#
#      Now add the following line right after the above code:
#
#          if FileTest.exist?(Scene_File::TEMP_SAVE_NAME)
#            @continue_enabled = true
#          end
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit and you'll see the configuration.
#
#   TEMP_SAVE_NAME: The name (and path if needed) for the temp save file.
#   TEMP_LOAD_TEXT: The message to be displayed when a temp save is loaded.
#   TEMP_SAVE_TEXT: The message to be displayed when asking for temp save
#                   confirmation.
#   DISABLE_PROMPT: If this is set to true, the prompt and confirmation windows
#                   will be disabled. (Please check Issues!)
#------------------------------------------------------------------------------
# Issues:
#
#     If DISABLE_PROMPT is activated, while loading or saving a quick-save,
#   there will be 2 sounds of button press instead of 1. Actually, it is the
#   sound of button press and the sound of saving and loading. Fixing this
#   means losing a lot of compatibility (since v2.0), so I have no intention
#   of doing that unless I get an idea which retains compatibility.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Fantasist, for making this script
#   dmoose for requesting this script
#   Hadeki for requesting the improvements
#------------------------------------------------------------------------------
# Notes:
#
#     If you have any problems, suggestions or comments, you can find me at:
#
#  - forum.chaos-project.com
#  - www.quantumcore.forumotion.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** Scene_Load
#==============================================================================

class Scene_File  
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # CONFIG START
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  TEMP_SAVE_NAME = 'Data/ScriptCache.rxdata'
  DISABLE_PROMPT = false
  TEMP_LOAD_TEXT = 'Quick load complete. Press Enter to continue.'
  TEMP_SAVE_TEXT = 'Do you want to quick save?'
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # CONFIG END
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  alias temp_save_main_hack main
  def main
    if $scene.is_a?(Scene_Load)
      if FileTest.exist?(TEMP_SAVE_NAME)
        main_quickload
      else
        temp_save_main_hack
      end
    elsif $scene.is_a?(Scene_Save)
      if @temp_save_active
        main_quicksave
      else
        temp_save_main_hack
      end
    end
  end
  
  def main_quickload
    unless DISABLE_PROMPT
      @prompt_window = Window_Prompt.new(TEMP_LOAD_TEXT)
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        break if Input.trigger?(Input::C)
      end
      Graphics.freeze
      @prompt_window.dispose
    end
    load_quicksave_data # Load Data
    # Load Map
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    $game_map.update
    $scene = Scene_Map.new
  end
  
  def load_quicksave_data
    $game_temp = Game_Temp.new unless $game_temp
    $game_system.se_play($data_system.load_se)
    file = File.open(TEMP_SAVE_NAME, 'rb')
    read_save_data(file)
    file.close
    File.delete(TEMP_SAVE_NAME)
  end
  
  def main_quicksave
    if DISABLE_PROMPT
      on_decision(TEMP_SAVE_NAME)
      $scene = Scene_Title.new
    else
      @prompt_window = Window_Prompt.new(TEMP_SAVE_TEXT, 1)
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update_quicksave
        break if $scene != self
      end
      Graphics.freeze
      @prompt_window.dispose
    end
  end
  
  def update_quicksave
    @prompt_window.update
    if Input.trigger?(Input::C)
      if @prompt_window.index == 0
        on_decision(TEMP_SAVE_NAME)
        $scene = Scene_Title.new
      else
        on_cancel
      end
    elsif Input.trigger?(Input::B)
      on_cancel
    end
  end
  
end

#==============================================================================
# ** Scene_Save
#==============================================================================

class Scene_Save
  
  alias temp_save_detect_menu initialize
  def initialize
    @temp_save_active = $scene.is_a?(Scene_Menu)
    temp_save_detect_menu
  end
  
end

#==============================================================================
# ** Window_Prompt
#==============================================================================

class Window_Prompt < Window_Base
  
  attr_reader :index
  
  def initialize(txt, mode=0, index=0)
    @txt, @mode = txt, mode
    width = text_width(txt) + 32
    width = 300 if width < 300
    height = 64 + mode * 64
    super(320 - width/2, 240 - height/2, width, height)
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    refresh
    @index = @mode > 0 ? index : -1
  end
  
  def text_width(text)
    b = Bitmap.new(1, 1)
    w = b.text_size(text).width
    b.dispose
    return w
  end
  
  def reset(txt, mode=0, index=0)
    @txt = txt unless txt == nil
    @mode = mode
    @index = @mode > 0 ? index : -1
    self.contents.dispose
    width = text_width(txt) + 32
    width = 300 if width < 300
    self.width, self.height = width, 64 + mode * 64
    self.x, self.y = 320 - self.width/2, 240 - self.height/2
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    refresh
    update_cursor_rect
  end
  
  def refresh
    self.contents.clear
    self.contents.draw_text(0, 0, self.width - 32, 32, @txt, 1)
    return unless @mode > 0
    self.contents.draw_text(self.width/2 - 16 - 34, 32, 68, 32, 'Yes', 1)
    self.contents.draw_text(self.width/2 - 16 - 34, 64, 68, 32, 'No', 1)
  end
  
  def index=(index)
    @index = index
    update_cursor_rect
  end
  
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    cursor_width = self.contents.text_size('  Yes  ').width
    x = (self.width - cursor_width)/2 - 16
    y = 32 + @index * 32
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  
  def update
    super
    return unless @mode > 0
    if self.active && @index >= 0
      if Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % 2
      elsif Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 3) % 2
      end
    end
    update_cursor_rect
  end
  
end