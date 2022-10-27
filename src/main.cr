require "./aerotitan"

begin
  Aerotitan::App.new.execute ARGV
rescue ex
  Aerotitan::Log.fatal ex
end
