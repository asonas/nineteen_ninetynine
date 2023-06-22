module NineteenNinetynine
  class Event
    class Note
      attr_accessor :body, :user, :date, :pubkey, :raw, :_mark, :_stream, :sig
      def initialize(content)
        @raw = content
        @body = content["content"]
        @pubkey = content["pubkey"]
        @date = Time.at content["created_at"]
        @_mark = nil
        @_stream = true
        @sig = content["sig"]
      end
    end
  end
end
