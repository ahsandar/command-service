class CommandService

  attr_accessor :commands, :log

  def initialize(cmd = nil, logger = nil, log_file='worker.log')
    @commands = ((cmd.is_a?Array)? cmd : [cmd])
    @commands.flatten!
    @commands.compact!
    @log ||= logger || LogService.new('command',File.join(LogService.log_directory, log_file))
  end

  def << (cmd)
    commands << cmd
  end

  def seperate_cmd
    commands << ';'
  end

  def execute(std_all=true)
    run_cmd(command,std_all)
  end

  def execute!(std_all=true)
    run_cmd(command,std_all) { reset_cmd! }
  end

  def self.run_now(cmds)
    self.new(cmds).execute!
  end

  def run_cmd(cmd, std_all = true, &reset_block)
    @log.msg "#{cmd}"
    cmd_result =( std_all ? %x[#{cmd} 2>&1] : %x[#{cmd}])
    @log.msg "output .... #{cmd_result}"
    reset_block.call if block_given?
    cmd_result
  end

  def reset_cmd!
    commands.clear
  end

  def timestamp_log
    @log.timestamp
  end

  def check_out_assets(file_assets, local_asset_path)
    file_assets.each do |file|
      file_name = File.join(local_asset_path, file.value)
      cms_file_path = file.cms_file_path
      @log.msg "copied #{cms_file_path}, #{file_name}"
      FileUtils.cp cms_file_path, file_name
    end
  end

  def remove_entry_secure(path)
    @log.msg "Removing entry secure: #{path}"
    if_exist = (Dir.exist?(path) || File.exists?(path))
    FileUtils.remove_entry_secure(path) if (if_exist && !DEBUG_MODE)
    log.msg "Removed entry secure: #{path}"
  end

  def remove_dir(folder)
    @log.msg "Removing dir folder: #{folder}"
    FileUtils.remove_dir folder if (Dir.exist?(folder) && !DEBUG_MODE)
    @log.msg "Removed dir folder: #{folder}"
    folder
  end

  def self.full_directory_path(folder)
    folder_path = File.join(Dir.getwd, folder)
    folder_path
  end

  def create_path_location(path)
    dir_path = File.expand_path(path)
    @log.msg "created path location: #{dir_path}"
    dir_path
  end

  def create_randomized_location(path)
    dir_path = File.join(path, random_sub_path, random_sub_path)
    FileUtils.mkdir_p dir_path
    @log.msg "created randomized location: #{dir_path}"
    dir_path
  end


  def copy_target_to_destination(source, destination)
    FileUtils.remove_entry_secure(destination) if File.exists?(destination)
    FileUtils.mkdir_p File.dirname(destination)
    FileUtils.cp_r source, destination
  end

  def random_sub_path
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0...5).map{ o[rand(o.length)] }.join
  end

  private

  def command
    commands.flatten!
    commands.join(' ')
  end


end