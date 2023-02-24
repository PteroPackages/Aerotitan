Colorize.on_tty_only!

module Aero::Log
  def self.info(msg : String) : Nil
    STDOUT.puts msg
  end

  def self.info(msgs : Array(String)) : Nil
    msgs.each { |m| info(m) }
  end

  def self.warn(msg : String) : Nil
    STDOUT.puts msg.colorize(:yellow).to_s
  end

  def self.warn(msgs : Array(String)) : Nil
    msgs.each { |m| warn(m) }
  end

  def self.error(msg : String) : Nil
    STDERR.puts msg.colorize(:red).to_s
  end

  def self.error(msgs : Array(String)) : Nil
    msgs.each { |m| error(m) }
  end

  def self.error(ex : Exception) : Nil
    STDERR.puts ex.to_s.colorize(:red).to_s
  end

  def self.fatal(msg : _) : NoReturn
    error msg
    exit 1
  end
end
