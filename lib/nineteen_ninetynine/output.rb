module NineteenNinetynine
  module Output
    def output
      insert do
        while item = item_queue.shift
          if item.user.nil?
            user = @users.find { |u| u.pubkey == item.raw["pubkey"] }
            item.user = user
          end

          puts_items(item.decorate)
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

    def puts_items(item)
      mark_color = config[:colors].sample + 10

      [items].flatten.reverse_each do |item|
        next if output_filters.any? { |f| f.call(item) == false }

        if item["text"] && !item["_stream"]
          item['_mark'] = ' '.c(mark_color) + item['_mark'].to_s
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
      @colors[screen_name.delete("^0-9A-Za-z_").to_i(36) % @colors].size
    end
  end
end
