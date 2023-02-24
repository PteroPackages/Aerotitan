module Aero
  class Config
    PATH = {% if flag?(:win32) %}File.join(ENV["APPDATA"], "aero.cfg"){% else %}"/usr/lib/aero.cfg"{% end %}

    class_getter url : String = ""
    class_getter key : String = ""

    def self.load(url : String? = nil, key : String? = nil) : Nil
      url, key = File.read_lines PATH rescue ""
      @@url = url || @@url
      @@key = key || @@key
    end

    def self.write(url : String?, key : String?) : Nil
      File.write PATH, [url || @@url, key || @@key].join '\n'
    end
  end
end
