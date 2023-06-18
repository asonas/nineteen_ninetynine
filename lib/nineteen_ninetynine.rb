# frozen_string_literal: true

require_relative "nineteen_ninetynine/version"
require "drb/drb"
require "drb/unix"

module NineteenNinetynine
  DRB_UNIX_SOCKET = "drbunix:/tmp/nineteen_ninetynine"

  class Error < StandardError; end

  def self.start
    child_pid fork do
      subscriber = Subscriber.new
      DRb.start_service(DRB_UNIX_SOCKET, subscriber, safe_level: 1)
    end
    Renderer.new.output

    Process.waitpid(child_pid)
  end
end
