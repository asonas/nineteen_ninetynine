require "websocket-client-simple"

module NineteenNinetynine
  class Subscriber
    attr_accessor :items
    def initialize
      @items = []
    end

    def start
      subscribe_to_events
    end

    def subscribe_to_events
      ws = WebSocket::Client::Simple.connect 'wss://nostr-relay.nokotaro.com'
      ws.on :message do |msg|
        puts "receive"
        puts msg.data
        payload = JSON.parse(msg.data)
        items.push payload

        case payload[0]
        when "EOSE"
          puts "Start time line: #{Time.now}"
        when "EVENT"
          case payload[1]
          when "content"
            puts payload


          when "user"

          end
        end
      end

      ws.on :open do
        puts "Hello nostr"
        ws.send JSON.generate(['REQ', 'content', { kinds: [1] }])
        ws.send JSON.generate(['REQ', 'user', { kinds: [0] }])
      end
    end
  end
end
