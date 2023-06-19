module NineteenNinetynine
  class Event
    class Note
      attr_accessor :body, :user, :date, :raw
      def initialize(content)
        @raw = content
        @body = content["content"]
        @date = Time.at content["created_at"]
      end

      def decorate
        "#{user&.name} #{body} #{date}"
      end
    end
  end
end
