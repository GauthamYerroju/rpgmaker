#==============================================================================
# ** Missing File Logger
#------------------------------------------------------------------------------
# by Fantasist
# Version: 1.0
# Date: 1-Mar-2009
#------------------------------------------------------------------------------
# Version History:
#
#   1.0 - First version
#------------------------------------------------------------------------------
# Description:
#
#     This script prevents the game from crashing due to missing files. It also
#   maintains a list of missing files. It can create a text file listing all
#   the lissing files, the latest time they were used and the number of times
#   they were used. It can also check for all the missing files. It any files
#   are found, they are removed from the list.
#------------------------------------------------------------------------------
# Compatibility:
#
#     Should be compatible with almost everything.
#------------------------------------------------------------------------------
# Instructions:
#
#     Place this script anywhere above "Main". I recommend you place it on top
#   of all scripts.
#
#   You can save the collected data by using the following code:
#               FTSConfig.save_missing_file_data
#
#   You can create a readable log file by using the following code:
#               FTSConfig.write_missing_file_data
#
#   You can check if any of the missing files are found by using:
#               FTSConfig.check_missing_files
#------------------------------------------------------------------------------
# Configuration:
#
#     Scroll down a bit for the configuration.
#
#   RESCUE_BITMAP(true/false): Whether an X is shown in place of a missing file.
#   SAVE_FREQUENCY_TYPE(0/1):
#     0: Saves the data to a file when the game exits. (FOLLOW EXTRA STEPS!!)
#     1: Saves the data to a file each time a missing resource is used.
#
#   Extra Steps:
#     Go to "Main". Erase the last line ("end") and paste the following code:
=begin
#===========Start copying from here===========
ensure
  FTSConfig.save_missing_file_data
  FTSConfig.write_missing_file_data
end
#=====================END=====================
=end
#
#   NOTE:
#
#   The data will be saved when:
#    - You close the game normally.
#    - You use Alt+F4 to close the game.
#    - The game crashes but an but some error message is displayed.
#
#   The data will NOT be saved when:
#    - You close the game by using the "End Task" command from the Task Manager
#------------------------------------------------------------------------------
# Issues:
#
#   None.
#------------------------------------------------------------------------------
# Credits and Thanks:
#
#   Credits: Fantasist for making this.
#------------------------------------------------------------------------------
# Notes:
#
#     If you have any questions, suggestions or comments, you can
#   find me (Fantasist) at:
#
#    - www.chaos-project.com
#    - www.quantumcore.forumotion.com
#
#   Enjoy ^_^
#==============================================================================

#==============================================================================
# ** FTSConfig
#==============================================================================

module FTSConfig
  
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # * CONFIG BEGIN
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  RESCUE_BITMAP = true
  SAVE_FREQUENCY_TYPE = 0
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # * CONFIG END
  #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  #--------------------------------------------------------------------------
  # * Load Missing File Data
  #--------------------------------------------------------------------------
  def self.load_missing_file_data
    if @missing_file_data == nil
      @missing_file_data = {}
    else
      f = File.open('Data/Missing File Data.rxdata', 'r')
      @missing_file_data = Marshal.load(f)
      f.close
    end
    self.check_missing_files
  end
  #--------------------------------------------------------------------------
  # * Save Missing File Data
  #--------------------------------------------------------------------------
  def self.save_missing_file_data
    f = File.open('Data/Missing File Data.rxdata', 'w')
    Marshal.dump(@missing_file_data, f)
    f.close
  end
  #--------------------------------------------------------------------------
  # * Check Missing Files
  #--------------------------------------------------------------------------
  def self.check_missing_files
    @missing_file_data.each_key do |key|
      @missing_file_data.delete(key) if FileTest.exist?(key)
    end
  end
  #--------------------------------------------------------------------------
  # * Log Missing File
  #--------------------------------------------------------------------------
  def self.log_missing_file(key)
    time = Time.now.strftime("%b-%d-%Y, %I:%M:%S")
    if @missing_file_data[key] == nil
      @missing_file_data[key] = [time, 1]
    else
      used_times = @missing_file_data[key][1]
      @missing_file_data[key] = [time, used_times + 1]
    end
  end
  #--------------------------------------------------------------------------
  # * Write Missing File Data
  #--------------------------------------------------------------------------
  def self.write_missing_file_data
    f = File.open('Missing File Log.txt', 'w')
    if @missing_file_data.empty?
      f.write('No files are missing.')
    else
      @missing_file_data.sort.each {|key, data| time, used = data[0], data[1]
      f.write("#{time} [#{used}]: #{key}\n")}
    end
    f.close
  end
  #--------------------------------------------------------------------------
  # * Load Missing File Data on Startup
  #--------------------------------------------------------------------------
  self.load_missing_file_data
end

#==============================================================================
# ** RPG::Cache
#==============================================================================

module RPG::Cache
  class << self
    #--------------------------------------------------------------------------
    # * Aliases
    #--------------------------------------------------------------------------
    alias fts_mfl_cache_load_bitmap load_bitmap
    #--------------------------------------------------------------------------
    # * Load Bitmap
    #--------------------------------------------------------------------------
    def load_bitmap(folder_name, filename, hue = 0)
      fts_mfl_cache_load_bitmap(folder_name, filename, hue)
    rescue
      FTSConfig.log_missing_file(folder_name + filename)
      if FTSConfig::SAVE_FREQUENCY_TYPE == 1
        FTSConfig.save_missing_file_data
      end
      return rescue_bitmap
    end
    #--------------------------------------------------------------------------
    # * Rescue Bitmap
    #--------------------------------------------------------------------------
    def rescue_bitmap
      if @cache['rescue_bitmap'] == nil || @cache['rescue_bitmap'].disposed?
        b = Bitmap.new(24, 24)
        if FTSConfig::RESCUE_BITMAP
          b.fill_rect(b.rect, Color.new(255, 255, 255))
          b.width.times {|i|
          b.set_pixel(i, i, Color.new(255, 0, 0))
          b.set_pixel(i, b.height-i, Color.new(255, 0, 0))}
        end
        @cache['rescue_bitmap'] = b
      end
      return @cache['rescue_bitmap']
    end
  end
end

#==============================================================================
# ** Audio
#==============================================================================

module Audio
  class << self
    #--------------------------------------------------------------------------
    # * Aliases
    #--------------------------------------------------------------------------
    alias fts_mfl_audio_bgm_play bgm_play
    alias fts_mfl_audio_bgs_play bgs_play
    alias fts_mfl_audio_me_play me_play
    alias fts_mfl_audio_se_play se_play
    #--------------------------------------------------------------------------
    # * Play Background Music
    #--------------------------------------------------------------------------
    def bgm_play(filename, volume=100, pitch=100)
      fts_mfl_audio_bgm_play(filename, volume, pitch)
    rescue
      FTSConfig.log_missing_file(filename)
    end
    #--------------------------------------------------------------------------
    # * Play Background Sound
    #--------------------------------------------------------------------------
    def bgs_play(filename, volume=100, pitch=100)
      fts_mfl_audio_bgs_play(filename, volume, pitch)
    rescue
      FTSConfig.log_missing_file(filename)
    end
    #--------------------------------------------------------------------------
    # * Play Play Music Effect
    #--------------------------------------------------------------------------
    def me_play(filename, volume=100, pitch=100)
      fts_mfl_audio_me_play(filename, volume, pitch)
    rescue
      FTSConfig.log_missing_file(filename)
    end
    #--------------------------------------------------------------------------
    # * Play Sound Effect
    #--------------------------------------------------------------------------
    def se_play(filename, volume=100, pitch=100)
      fts_mfl_audio_se_play(filename, volume, pitch)
    rescue
      FTSConfig.log_missing_file(filename)
    end
  end
end