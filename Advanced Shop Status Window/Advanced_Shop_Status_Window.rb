#============================================================================
# ** Advanced Shop Status Window
#----------------------------------------------------------------------------
# by RPG Advocate
# Cleaned, optimized and re-documented by Fantasist
# Version 2.0
# 9-June-2008
#----------------------------------------------------------------------------
# Version History:
#
#   1.0 - Original version by RPG Advocate
#   2.0 - Cleaned and fixed by Fantasist
#----------------------------------------------------------------------------
# Description:
#
#     This script enhances the way the stat increases are shown
#   in the shop status window when viewing weapons and armors.
#----------------------------------------------------------------------------
# Compatibility:
#
#     Might not be compatible with other shop scene modifications
#   or complete overhauls (since they have their own status
#   windows).
#----------------------------------------------------------------------------
# Instructions:
#
#     Place this script anywhere below 'Window_ShopStatus' and
#   above 'Main'.
#----------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit and you'll see lots of constants. Two of them
#   are the config.
#
#         PLUS_COLOR = Color.new(128, 255, 128)
#         MINUS_COLOR = Color.new(255, 128, 128)
#
#   Those are the colors for showing increase ad decrease in stats.
#   For changing them, remember what the numbers mean:
#
#               Color.new(red, green, blue)
#
#      I wouldn't recommend you touch the other constants.
#   They're just the positions of some text (the stat changes).
#
#     If you want to change any words like "Posessed",
#   "Cannot Equip", "Currently Equipped", etc, just scroll down
#   until you find them and change them to your liking.
#----------------------------------------------------------------------------
# Issues:
#
#     None so far.
#----------------------------------------------------------------------------
# Credits and Thanks:
#
#     Credit RPG Advocate for the layout. You must credit him,
#   because this was originally his script. You can credit me if you
#   want, because the original version had some annoying glitches.
#----------------------------------------------------------------------------
# Notes:
#
#     The original version had some glitches, mainly the characters
#   staying visible when they were not supposed to.  Then, change
#   in intelligence was shown as change in pdef (not sure which
#   stat...). Next, the text size for Cannot Equip, Currently Equipped
#   etc., was smaller for some actors. It actually might not be a glitch
#   since it was pretty cool imo, but it looked wierd in some cases.
#   If you want to know what i mean, hit Ctrl+F and type in:
#                            text_size_glitch
#   When you find the lines, comment them. There ought be 2-3 lines.
#
#   The original script was found at RPG Advocate's site:
#   www.phylomortis.com
#============================================================================

#=============================================================================
# ** Window_ShopStatus
#=============================================================================

class Window_ShopStatus
  
  PLUS_COLOR = Color.new(128, 255, 128)
  MINUS_COLOR = Color.new(255, 128, 128)
  
  # Do not touch anything below unless you know what you're doing
  
  SIGN_WIDTH = 8
  
  STAT_NAME_C1 = 32
  STAT_NAME_C2 = 104
  STAT_NAME_C3 = 176
  
  STAT_SIGN_C1 = STAT_NAME_C1 + 28
  STAT_SIGN_C2 = STAT_NAME_C2 + 28
  STAT_SIGN_C3 = STAT_NAME_C3 + 22
  
  STAT_VAL_C1 = STAT_SIGN_C1 + SIGN_WIDTH + 2
  STAT_VAL_C2 = STAT_SIGN_C2 + SIGN_WIDTH + 2
  STAT_VAL_C3 = STAT_SIGN_C3 + SIGN_WIDTH + 2
  
  def initialize
    super(368, 128, 272, 352)
    self.contents = Bitmap.new(width-32, height-32)
    @item = nil
    @sprites = [Sprite.new, Sprite.new, Sprite.new, Sprite.new]
    @sprites.each_with_index {|sprite, i|
      sprite.x = 380
      sprite.y = 194 + i * 64
      sprite.z = self.z + 10
    }
    @walk = [false, false, false, false]
    @count = 0
    refresh
  end
  
  def refresh
    self.contents.clear
    @sprites.each {|sprite| sprite.visible = false}
    return if @item == nil
    self.contents.font.size = 24
    number = case @item
    when RPG::Item then $game_party.item_number(@item.id)
    when RPG::Weapon then $game_party.weapon_number(@item.id)
    when RPG::Armor then $game_party.armor_number(@item.id)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 200, 32, 'Possessed:')
    self.contents.font.color = normal_color
    self.contents.draw_text(204, 0, 32, 32, number.to_s, 2)
    if @item.is_a?(RPG::Item)
      @walk = [false, false, false, false]
      return
    end
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if @item.is_a?(RPG::Weapon)
        item1 = $data_weapons[actor.weapon_id]
      elsif @item.kind == 0
        item1 = $data_armors[actor.armor1_id]
      elsif @item.kind == 1
        item1 = $data_armors[actor.armor2_id]
      elsif @item.kind == 2
        item1 = $data_armors[actor.armor3_id]
      else
        item1 = $data_armors[actor.armor4_id]
      end
      if !actor.equippable?(@item)
        draw_actor_graphic(i, false)
        self.contents.font.size = 24  # text_size_glitch
        self.contents.font.color = normal_color
        self.contents.draw_text(32, 54 + 64 * i, 150, 32, 'Cannot Equip')
      else
        draw_actor_graphic(i, true)
        str1 = item1 != nil ? item1.str_plus : 0
        str2 = @item != nil ? @item.str_plus : 0
        dex1 = item1 != nil ? item1.dex_plus : 0
        dex2 = @item != nil ? @item.dex_plus : 0
        agi1 = item1 != nil ? item1.agi_plus : 0
        agi2 = @item != nil ? @item.agi_plus : 0
        int1 = item1 != nil ? item1.int_plus : 0
        int2 = @item != nil ? @item.int_plus : 0
        pdf1 = item1 != nil ? item1.pdef : 0
        pdf2 = @item != nil ? @item.pdef : 0
        mdf1 = item1 != nil ? item1.mdef : 0
        mdf2 = @item != nil ? @item.mdef : 0
        atk1 = atk2 = eva1 = eva2 = 0
        if @item.is_a?(RPG::Weapon)
          atk1 = item1 != nil ? item1.atk : 0
          atk2 = @item != nil ? @item.atk : 0
        end
        if @item.is_a?(RPG::Armor)
          eva1 = item1 != nil ? item1.eva : 0
          eva2 = @item != nil ? @item.eva : 0
        end
        str_change = str2 - str1
        dex_change = dex2 - dex1
        agi_change = agi2 - agi1
        int_change = int2 - int1
        pdf_change = pdf2 - pdf1
        mdf_change = mdf2 - mdf1
        atk_change = atk2 - atk1
        eva_change = eva2 - eva1
        name1 = item1 == nil ? '' : item1.name
        name2 = @item == nil ? '' : @item.name
        if str_change == 0 && dex_change == 0 && agi_change == 0 && 
        pdf_change == 0 && mdf_change == 0 && atk_change == 0 &&
        eva_change == 0 && int_change == 0 && name1 != name2
          self.contents.font.size = 24  # text_size_glitch
          self.contents.font.color = normal_color
          self.contents.draw_text(32, 54 + 64 * i, 150, 32, 'No Change')
        end
        if name1 == name2
          self.contents.font.size = 24  # text_size_glitch
          self.contents.font.color = normal_color
          self.contents.draw_text(32, 54 + 64 * i, 200, 32, 'Currently Equipped')
        end
        self.contents.font.size = 16
        self.contents.font.color = normal_color
        if @item.is_a?(RPG::Weapon) && atk_change != 0
          self.contents.draw_text(STAT_NAME_C1, 42 + 64 * i, 32, 32, 'ATK')
        end
        if @item.is_a?(RPG::Armor) && eva_change != 0
          self.contents.draw_text(STAT_NAME_C1, 42 + 64 * i, 32, 32, 'EVA')
        end
        if pdf_change != 0
          self.contents.draw_text(STAT_NAME_C1, 58 + 64 * i, 32, 32, 'PDF')
        end
        if mdf_change != 0
          self.contents.draw_text(STAT_NAME_C1, 74 + 64 * i, 32, 32, 'MDF')
        end
        if str_change != 0
          self.contents.draw_text(STAT_NAME_C2, 42 + 64 * i, 32, 32, 'STR')
        end
        if dex_change != 0
          self.contents.draw_text(STAT_NAME_C2, 58 + 64 * i, 32, 32, 'DEX')
        end
        if agi_change != 0
          self.contents.draw_text(STAT_NAME_C2, 74 + 64 * i, 32, 32, 'AGI')
        end
        if int_change != 0
          self.contents.draw_text(STAT_NAME_C3, 42 + 64 * i, 32, 32, 'INT')
        end
        if @item.is_a?(RPG::Weapon) && atk_change > 0
          self.contents.font.color = PLUS_COLOR
          s = atk_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 42 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(70, 42 + 64 * i, 24, 32, s)
        elsif @item.is_a?(RPG::Weapon) && atk_change < 0
          self.contents.font.color = MINUS_COLOR
          s = atk_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 42 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C1, 42 + 64 * i, 24, 32, s)
        end
        if @item.is_a?(RPG::Armor) && eva_change > 0
          self.contents.font.color = PLUS_COLOR
          s = eva_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 42 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C1, 42 + 64 * i, 24, 32, s)
        elsif @item.is_a?(RPG::Armor) && eva_change < 0
          self.contents.font.color = MINUS_COLOR
          s = eva_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 42 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C1, 42 + 64 * i, 24, 32, s)
        end
        if pdf_change > 0
          self.contents.font.color = PLUS_COLOR
          s = pdf_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 58 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C1, 58 + 64 * i, 24, 32, s)
        elsif pdf_change < 0
          self.contents.font.color = MINUS_COLOR
          s = pdf_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 58 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C1, 58 + 64 * i, 24, 32, s)
        end
        if mdf_change > 0
          self.contents.font.color = PLUS_COLOR
          s = mdf_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 74 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C1, 74 + 64 * i, 24, 32, s)
        elsif mdf_change < 0
          self.contents.font.color = MINUS_COLOR
          s = mdf_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C1, 74 + 64 * i, SIGN_WIDTH, 32, '-',1)
          self.contents.draw_text(STAT_VAL_C1, 74 + 64 * i, 24, 32, s)
        end
        if str_change > 0
          self.contents.font.color = PLUS_COLOR
          s = str_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 42 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C2, 42 + 64 * i, 24, 32, s)
        elsif str_change < 0
          self.contents.font.color = MINUS_COLOR
          s = str_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 42 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C2, 42 + 64 * i, 24, 32, s)
        end
        if dex_change > 0
          self.contents.font.color = PLUS_COLOR
          s = dex_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 58 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C2, 58 + 64 * i, 24, 32, s)
        elsif dex_change < 0
          self.contents.font.color = MINUS_COLOR
          s = dex_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 58 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C2, 58 + 64 * i, 24, 32, s)
        end
        if agi_change > 0
          self.contents.font.color = PLUS_COLOR
          s = agi_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 74 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C2, 74 + 64 * i, 24, 32, s)
        elsif agi_change < 0
          self.contents.font.color = MINUS_COLOR
          s = agi_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C2, 74 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C2, 74 + 64 * i, 24, 32, s)
        end
        if int_change > 0
          self.contents.font.color = PLUS_COLOR
          s = int_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C3, 42 + 64 * i, SIGN_WIDTH, 32, '+', 1)
          self.contents.draw_text(STAT_VAL_C3, 42 + 64 * i, 24, 32, s)
        elsif int_change < 0
          self.contents.font.color = MINUS_COLOR
          s = int_change.abs.to_s
          self.contents.draw_text(STAT_SIGN_C3, 42 + 64 * i, SIGN_WIDTH, 32, '-', 1)
          self.contents.draw_text(STAT_VAL_C3, 42 + 64 * i, 24, 32, s)
        end
      end
    end
  end
  
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
  
  def draw_actor_graphic(id, equipable)
    actor = $game_party.actors[id]
    @sprites[id].bitmap = RPG::Cache.character(actor.character_name,
    actor.character_hue)
    @sprites[id].src_rect.set(0, 0, @sprites[id].bitmap.width / 4,
    @sprites[id].bitmap.height / 4)
    @walk[id] = equipable
    @sprites[id].tone = Tone.new(0, 0, 0, equipable ? 0 : 255)
    @sprites[id].visible = true
  end
  
  def update
    super
    @count = (@count + 1) % 40
    (0..3).each {|i|
      next unless @walk[i]
      if @sprites[i].bitmap != nil
        w = @sprites[i].bitmap.width / 4
        h = @sprites[i].bitmap.height / 4
        x = (@count / 10) * w
        @sprites[i].src_rect.set(x, 0, w, h)
      end
    }
  end
  
  def visible=(val)
    super
    @sprites.each {|sprite| sprite.visible = val if sprite}
  end
  
  def dispose
    super
    @sprites.each {|sprite| sprite.dispose if sprite}
  end
  
end