# require 'stringio'
# require 'monitor'

require_relative "initializer"

module NineteenNinetynine
  module Renderer
    attr_accessor :items, :users, :item_queue, :loaded
    def items
      @items ||= []
    end

    def users
      @users ||= []
    end

    def item_queue
      @item_queue ||= []
    end

    def colors
      (31..36).to_a + (91..96).to_a
    end
  end
end
