module NineteenNinetynine
  module Output
    def output(name = nil, &block)
      if block
        outputs.delete_if { |o| o[:name] == name } if name
        outputs << { name: name, block: block }
      else
        insert do
          while note = @notes.shift
            if note.user.nil?
              sleep 1
              # users = $cache.read("users")
              user = @users.find { |u| u.pubkey == note.raw["pubkey"] }
              note.user = user
              puts_items(note)
            else
              puts_items(note)
            end
          end
        end
      end
    end

    def output_filters
      @output_filters ||= []
    end

    def output_filter(&block)
      output_filters << block
    end

    def outputs
      @outputs ||= []
    end

    def puts_items(items)
      mark_color = colors.sample + 10

      [items].flatten.reverse_each do |item|
        next if output_filters.any? { |f| f.call(item) == false }

        if item.body && !item._stream
          item._mark = ' '.c(mark_color) + item._mark.to_s
        end

        outputs.each do |o|
          begin
            o[:block].call(item)
          rescue => e
            error e
          end
        end
      end
    end

    def insert(*messages)
      monitor.synchronize do
        begin
          try_swap = !$stdout.is_a?(StringIO)
          $stdout = StringIO.new if try_swap

          puts messages
          yield if block_given?

          unless $stdout.string.empty?
            STDOUT.print "\e[0G\e[K#{$stdout.string}"
            Readline.refresh_line
          end
        ensure
          $stdout = STDOUT if try_swap
        end
      end
    end

    def monitor
      @monitor ||= Monitor.new
    end

    def color_of(name)
      colors =  (31..36).to_a + (91..96).to_a
      colors[name.delete("^0-9A-Za-z_").to_i(36) % colors.size]
    end
  end
end
