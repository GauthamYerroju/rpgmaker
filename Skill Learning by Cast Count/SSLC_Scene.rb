#============================================================================
# ** SLCC Information Scene
#----------------------------------------------------------------------------------------
# by Fantasist
# Version 0.2
# 28-Aug-2008
#----------------------------------------------------------------------------------------
# Version History:
#
#   0.2 - Alpha stage version, just for checking out the learning trees
#----------------------------------------------------------------------------------------
# Description:
#
#     This is the scene for checking skill learning information by using the
#   script SLCC (Skill Learning by Cast Count).
#----------------------------------------------------------------------------------------
# Compatibility:
#
#     This is useless and will give an error if you're not using SLCC.
#   Place this below SLCC. This is a seperate scene, so it should be
#   compatible with almost anything.
#----------------------------------------------------------------------------------------
# Instructions/Configuration:
#
#   There's nothing to configure for this version. You can call the scene by
#   using the following piece of code in a "Call Script" event command:
#
#           $scene = Scene_SkillLearnInfo.new
#
#     During the scene, press L and R to cycle between all the actors in the
#   party.
#----------------------------------------------------------------------------------------
# Issues:
#
#     1 - This will give an error if it is called when the party is empty.
#     2 - For this version, there are no sounds.
#     3 - You can't check multiple skill requirements with this scene, it
#          focuses on only ONE skill at a time and displays all the skills that
#          you can learn by using it different times.
#----------------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Credit: Fantasist for making this.
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
# ** Window_SkillList
#==============================================================================

class Window_SkillList < Window_Selectable
  
  def initialize(actor)
    super(0, 64, 240, 416)
    @actor, @column_max = actor, 1
    refresh
    self.index = 0
  end
  
  def skill
    return @data[self.index]
  end
  
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 0...@actor.skills.size
      skill = $data_skills[@actor.skills[i]]
      @data.push(skill) if skill != nil
    end
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  
  def draw_item(index)
    skill, x, y = @data[index], 4, index * 32
    self.contents.font.color = normal_color
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 204, 32, skill.name, 0)
  end
  
  def update_help
    @help_window.set_text(self.skill == nil ? '' : self.skill.description)
  end
  
end

#==============================================================================
# ** Window_SkillInfo
#==============================================================================

class Window_SkillInfo < Window_Base
  
  def initialize(actor)
    @actor = actor
    super(240, 64, 400, 416)
    refresh
  end
  
  def refresh(skill=nil)
    return unless skill
    self.oy = 0
    a, size = FTS::learn_new_skills?(@actor.id, skill.id), 0
    a.each {|c| size += c.size} if a
    self.contents.dispose if self.contents
    self.contents = Bitmap.new(width - 32, 96 + size * 32)
    self.contents.font.size = 28
    contents.draw_text(0, 0, contents.width, 64, @actor.name, 1)
    self.contents.font.size = 22
    draw_actor_graphic(@actor, 320, 64)
    txt = "Times used: #{@actor.skill_uses[skill.id]}"
    contents.draw_text(4, 64, contents.width - 8, 32, txt)
    return unless a
    y = 96
    a.each_with_index {|c, i| times = c.shift
    contents.draw_text(4, y, contents.width - 8, 32, "When used #{times} time(s), learns:")
    y += 32
    c.size.times {|i| skill_id = c[i]
    rect = Rect.new(4, y + 4, 24, 24)
    contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon($data_skills[skill_id].icon_name)
    contents.blt(rect.x, rect.y, bitmap, Rect.new(0, 0, 24, 24))
    contents.draw_text(32, y, contents.width - 36, 32, "#{$data_skills[skill_id].name}")
    y += 32}}
    if contents.height > self.height - 32
      self.contents.font.size = 16
      contents.draw_text(4, 0, contents.width - 8, 24, 'Hold SHIFT and press UP/DOWN', 1)
    end
  end
  
  def update
    super
    if self.active && contents.height > self.height - 32
      if Input.press?(Input::DOWN) && (contents.height - oy > self.height - 32)
        self.oy += 2
      elsif Input.press?(Input::UP) && (oy > 0)
        self.oy -= 2
      end
    end
  end
  
end

#==============================================================================
# Scene_SkillLearnInfo
#==============================================================================

class Scene_SkillLearnInfo
  
  def initialize(actor_index=0)
    @actor_index = actor_index
    $data_skills = load_data('Data/Skills.rxdata') unless $data_skills
  end
  
  def main
    @actor = $game_party.actors[@actor_index]
    @help_win = Window_Help.new
    @list_win = Window_SkillList.new(@actor)
    @list_win.help_window = @help_win
    @info_win = Window_SkillInfo.new(@actor)
    @info_win.refresh(@list_win.skill)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    @help_win.dispose
    @list_win.dispose
    @info_win.dispose
  end
  
  def update
    if @list_win.active
      update_list
    elsif @info_win.active
      update_info
    end
    @info_win.active = Input.press?(Input::A)
    @list_win.active = !@info_win.active
  end
  
  def update_list
    @help_win.update
    @list_win.update
    if Input.trigger?(Input::B)
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::L)
      new_index = (@actor_index - 1) % $game_party.actors.size
      $scene = Scene_SkillLearnInfo.new(new_index)
    elsif Input.trigger?(Input::R)
      new_index = (@actor_index + 1) % $game_party.actors.size
      $scene = Scene_SkillLearnInfo.new(new_index)
    elsif Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)
      @info_win.refresh(@list_win.skill)
    end
  end
  
  def update_info
    @info_win.update
  end
  
end
