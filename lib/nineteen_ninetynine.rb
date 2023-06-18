# frozen_string_literal: true

require_relative "nineteen_ninetynine/version"
require_relative "nineteen_ninetynine/renderer"
require_relative "nineteen_ninetynine/subscriber"
require 'eventmachine'
require 'readline'

module NineteenNinetynine
  class Error < StandardError; end

  def self.start
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

      Subscriber.new.start
      EM.add_periodic_timer(3) do

      end
    end
  end
end
