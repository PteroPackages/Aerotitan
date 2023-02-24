require "./aero"

begin
  Aero::CLI.new.execute ARGV
  # not helpful right now
  # rescue ex
  # Aero::Log.fatal ex
end
