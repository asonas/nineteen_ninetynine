module NineteenNinetynine
  module Core
    def _init
      inits.each { |block| class_eval(&block) }
    end
    def users
      @users ||= []
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

        EM.add_periodic_timer(1) do
          # Reconnect
          # if @last_data_received_at && Time.now - @last_data_received_at > 30
          #   # stop_stream
          #   start_stream
          # end

          mutex = Mutex.new
          mutex.synchronize do
            output
          end
        end

        start_stream
      end
    end

    def stop_stream
      @ws.close if @ws.open?
      @ws = nil
    end

    def create_ws_client
      @ws ||= WebSocket::Client::Simple.connect "wss://relay-jp.nostr.wirednet.jp"
    end

    def create_notes
      @notes ||= []
    end

    def create_users
      @users ||= []
    end

    def create_last_data_received_at
      @last_data_received_at ||= Time.now
    end

    def last_data_received_at=(time)
      @last_data_received_at = time
    end

    def error(e)
      case e
      when Exception
        insert "[ERROR] #{e.message}\n    #{e.backtrace.join("\n    ")}".c(:notice)
      else
        insert "[ERROR] #{e}".c(:notice)
      end
    end

    def start_stream
      users = create_users
      notes = create_notes
      create_last_data_received_at

      ws = create_ws_client

      ws.on :message do |msg|
        next if msg.data.empty?

        payload = JSON.parse(msg.data)

        case payload[0]
        when "EOSE"
          # puts "Start time line: #{Time.now}"
        when "EVENT"
          case payload[1]
          when "content"
            note = Event::Note.new(payload[2])
            user = users.find { |u| u.pubkey == payload[2]["pubkey"] }
            if user.nil?
              ws.send JSON.generate(["REQ", "user", { kinds: [0], authors: [payload[2]["pubkey"]] }])

              while user = users.find { |u| u.pubkey == payload[2]["pubkey"] }
                note.user = user
                sleep 0.1
              end
            else
              note.user = user
            end

            notes.push note
          when "user"
            # user = User.new(JSON.parse(payload[2]["content"])["name"], payload[2]["pubkey"])
            profile = Event::Profile.new(payload[2])
            users.push profile
          end
        end
      rescue JSON::ParserError => e
        # ignore
      end

      ws.on :open do
        ws.send JSON.generate(["REQ", "content", { kinds: [1], since: Time.now.to_i }])
        ws.send JSON.generate(["REQ", "user", { kinds: [0] }])
      end

      ws.on :close do |e|
      end

      ws.on :error do |e|
        puts e
        puts e.backtrace
      end
    end
  end
end
