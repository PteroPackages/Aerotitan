module Aerotitan
  class Config
    # PATH = File.join {% if flag?(:win32) %}ENV["APPDATA"]{% else %}"/etc"{% end %}, "aerotitan.cfg"
    PATH = {% if flag?(:win32) %}File.join(ENV["APPDATA"], "aerotitan.cfg"){% else %}"/etc/aerotitan"{% end %}

    class_getter url : String = ""
    class_getter key : String = ""

    def self.load(url : String?, key : String?) : Nil
      url, key = File.read_lines PATH rescue ""
      @@url = url || @@url
      @@key = key || @@key
    end

    def self.write(url : String?, key : String?) : Nil
      File.write PATH, [url || @@url, key || @@key].join '\n'
    end
  end
end
