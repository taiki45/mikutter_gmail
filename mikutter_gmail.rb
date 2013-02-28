# -*- coding: utf-8 -*-
require 'mikutter_plugin_base'
require 'gmail'

module MikutterGmail
  class Mailer
    class << self
      def primary
        @primary ||= ::Gmail.connect(*setting)
      end

      def setting
        @setting ||= YAML.load(open(File.expand_path('../config.yaml', __FILE__))).values
      end
    end

    def primary
      self.class.primary
    end

    def send(_to, _subject, _body)
      primary.deliver do
        to _to
        subject _subject
        text_part do
          body _body
        end
      end
    end
  end

  class Plugin < Mikutter::PluginBase
    def self.pattern
      @pattern ||= /^@mail\n+
                    to:(?<to>.*)\n+
                    subject:(?<subject>.*)\n+
                    (?<body>.*)$
                    /xu
    end

    def pattern
      self.class.pattern
    end

    def run(plugin)
    end

    def filter_gui_postbox_post(box)
      buff = ::Plugin.create(:gtk).widgetof(box).widget_post.buffer
      if buff.text =~ pattern
        Mailer.new.send(*$~[1..3])
        buff.text = ""
      end
      [box]
    end
  end
end

MikutterGmail::Plugin.register!
