module NineteenNinetynine
  module Core
    def _init
      inits.each { |block| class_eval(&block) }
    end

    def start
      _init

      EM.run do
        Thread.start do
          while buf = Readline.readline("Nostr: ", true)
            unless Readline::HISTORY.count == 1
              Readline::HISTORY.pop if buf.empty? || Readline::HISTORY[-1] == Readline::HISTORY[-2]
            end
            #sync {
            #  reload unless config[:reload] == false
            #  store_history
            #  input(buf.strip)
            #}
            puts buf.strip
          end
          # unexpected
          #stop
        end

        start_stream
      end
    end

    def start_stream
      loaded = false
      ws = WebSocket::Client::Simple.connect "wss://relay-jp.nostr.wirednet.jp"

      ws.on :message do |msg|
        next if msg.data.empty?

        payload = JSON.parse(msg.data)

        case payload[0]
        when "EOSE"
          #puts "Start time line: #{Time.now}"
          loaded = true
        when "EVENT"
          next unless loaded
          case payload[1]
          when "content"
            puts "content"
            date = Time.at payload[2]["created_at"]
            content = payload[2]["content"]
            note = Event::Note.new(payload[2])
            user = users.find { |u| u.pubkey == payload[2]["pubkey"] }
            if user.nil?
              ws.send JSON.generate(["REQ", "user", { kinds: [0], authors: [payload[2]["pubkey"]] }])
            else
              note.user = user
            end
            puts note

            item_queue.push note
          when "user"
            user = User.new(JSON.parse(payload[2]["content"])["name"], payload[2]["pubkey"])
            users.push user
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
          output
        end
      end
    end

  end
end
