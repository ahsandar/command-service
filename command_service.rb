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

  private

  def command
    commands.flatten!
    commands.join(' ')
  end


end