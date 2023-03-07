require "./aero"

begin
  Aero::CLI.new.execute ARGV
rescue Aero::SystemExit
end
