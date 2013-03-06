# -*- coding: utf-8 -*-
require 'gmail'

module MikutterGmail
  class Mailer
    class << self
      def primary
        @primary ||= Gmail.connect(*setting)
      end

      def setting
        @setting ||= YAML.load_file(File.expand_path('../config.yaml', __FILE__)).values
      end
    end

    def initialize
      @last_unread_count = 0
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

    def unread_count
      count = primary.inbox.count(:unread)
      change_countp = !(@last_unread_count == count)
      @last_unread_count = count
      change_countp ? count : 0
    end
  end

  Plugin.create :gmail do
    def tell(msg)
      ::Plugin.call(:update, nil, [Message.new(message: msg, system: true)])
    end

    valid = /
      ^@mail\s+
      to:(.*)\n+
      subject:(.*)\n+
      ((?:.|\n)*)$
    /xu
    invalid = /^@mail\s+(.*)/m

    mailer = Mailer.new
    at_exit { mailer.primary.logout }

    filter_gui_postbox_post do |box|
      buff = ::Plugin.create(:gtk).widgetof(box).widget_post.buffer

      case buff.text
      when valid
        Thread.new($~) do |matched|
          tell "送信中です☆"
          result = mailer.send(*matched[1..3])
          response = result ? "上手く送れたみたいだよ☆\n\n#{result}" : "失敗したみたい…\ntext:\n#{matched}\nresult:\n#{result}"
          tell response
        end
        buff.text = ""
      when invalid
        tell "フォーマットが違うかも..?\n#{$~}"
        buff.text = ""
      end
      [box]
    end

    on_period do
      Thread.new do
        count = mailer.unread_count
        tell "未読メールがあるよー☆ 未読数#{count}" if count > 0
      end
    end
  end
end
