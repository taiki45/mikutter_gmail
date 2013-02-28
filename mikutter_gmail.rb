# -*- coding: utf-8 -*-
require 'mikutter_plugin_base'
require 'gmail'

module MikutterGmail
  class Mailer
    class << self
      def primary
        @primary ||= Gmail.connect(*setting)
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
      @pattern ||= /^@mail\s+
                    to:(.*)\n+
                    subject:(.*)\n+
                    ((?:.|\n)*)$
                    /xu
    end

    def pattern
      self.class.pattern
    end

    def run(plugin)
    end

    def tell(msg)
      ::Plugin.call(:update, nil, [::Message.new(message: msg, system: true)])
    end

    def filter_gui_postbox_post(box)
      buff = ::Plugin.create(:gtk).widgetof(box).widget_post.buffer

      case buff.text
      when pattern
        Thread.new($~) do |matched|
          tell "Sending mail..."
          result = Mailer.new.send(*matched[1..3])
          response = result ? "Sent successfully.\n\n#{result}" : "Failed to send mail.\ntext:\n#{matched}\nresult:\n#{result}"
          tell response
        end
        buff.text = ""
      when /^@mail\s+(.*)/m
        tell "フォーマットが違うかも..?\n#{$~}"
        buff.text = ""
      end
      [box]
    end
  end
end

MikutterGmail::Plugin.register!
