require "websocket-client-simple"

module NineteenNinetynine
  class Subscriber
    User = Data.define :name, :pubkey
    Item = Data.define :content, :user, :date

    def initialize
    end

    def start
      subscribe_to_events
    end

    def subscribe_to_events
      loaded = false
      renderer = Renderer.new
      ws = WebSocket::Client::Simple.connect "wss://relay-jp.nostr.wirednet.jp"

      ws.on :message do |msg|
        next if msg.data.empty?

        payload = JSON.parse(msg.data)

        case payload[0]
        when "EOSE"
          puts "Start time line: #{Time.now}"
          renderer.loaded = true
          puts "Loaded past content!"
        when "EVENT"
          next unless renderer.loaded
          case payload[1]
          when "content"
            date = Time.at payload[2]["created_at"]
            content = payload[2]["content"]
            note = Event::Note.new(payload[2])
            user = renderer.users.find { |u| u.pubkey == payload[2]["pubkey"] }
            if user.nil?
              hex = NineteenNinetynine::Utils.scripted_pubkey(payload[2]["pubkey"])
              ws.send JSON.generate(["REQ", "user", { kinds: [0], authors: [hex] }])
            else
              note.user = user
            end
            renderer.item_queue.push note
            # puts ">>#{user&.name} #{content} #{date}"
          when "user"
            user = User.new(JSON.parse(payload[2]["content"])["name"], payload[2]["pubkey"])
            renderer.users.push user
          end
        end
      rescue JSON::ParserError => e
        puts e
        puts msg.data
      end

      ws.on :open do
        ws.send JSON.generate(['REQ', 'content', { kinds: [1] }])
        ws.send JSON.generate(['REQ', 'user', { kinds: [0] }])
      end

      ws.on :close do |e|
        p e.backtrace
        exit 1
      end

      ws.on :error do |e|
        puts e
        puts e.backtrace
      end

      EM.add_periodic_timer(1) do
        mutex = Mutex.new
        mutex.synchronize do
          renderer.output
        end
      end
    end
  end
end
