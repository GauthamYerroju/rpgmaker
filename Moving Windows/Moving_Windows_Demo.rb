# Moving Windows Demo: Scene_Menu modded with moving windows

class Scene_Menu

  def main
    s1 = $data_system.words.item
    s2 = $data_system.words.skill
    s3 = $data_system.words.equip
    s4 = 'Status'
    s5 = 'Save'
    s6 = 'End Game'
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    @command_window.y = -224
    if $game_party.actors.size == 0
      (0..3).each {|i| @command_window.disable_item(i)}
    end
    @command_window.disable_item(4) if $game_system.save_disabled
    # Make play time window
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = -160
    @playtime_window.y = 224
    # Make steps window
    @steps_window = Window_Steps.new
    @steps_window.x = -160
    @steps_window.y = 320
    # Make gold window
    @gold_window = Window_Gold.new
    @gold_window.x = -160
    @gold_window.y = 416
    # Make status window
    @status_window = Window_MenuStatus.new
    @status_window.x = 640
    @status_window.y = 0
    # Move the windows
    @command_window.move(0, 0)
    @playtime_window.move(0, 224)
    @steps_window.move(0, 320)
    @gold_window.move(0, 416)
    @status_window.move(160, 0)
    
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  
  alias moving_wins_test_menu_upd update
  def update
    @command_window.move(0, 0)
    @playtime_window.move(0, 224)
    @steps_window.move(0, 320)
    @gold_window.move(0, 416)
    @status_window.move(160, 0)
    moving_wins_test_menu_upd
  end
  
end
