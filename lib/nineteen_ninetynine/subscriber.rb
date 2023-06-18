module NineteenNinetynine
  class Subscriber
    def start
      subscribe_to_events
    end

    def subscribe_to_events
      ws = WebSocket::Client::Simple.connect 'wss://relay-jp.nostr.wirednet.jp'
      ws.on :message do |msg|
        payload = JSON.parse(msg.data)

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
        ws.send JSON.generate(['REQ', 'content', { kinds: [1] }])
        ws.send JSON.generate(['REQ', 'user', { kinds: [0] }])
      end
    end
  end
end
