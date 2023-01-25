require "./aerotitan"

begin
  Aerotitan::App.new.execute ARGV
  # not helpful right now
  # rescue ex
  # Aerotitan::Log.fatal ex
end
