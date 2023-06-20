module NineteenNinetynine
  module Initializer
    def inits
      @inits ||= []
    end

    def init(&block)
      inits << block
    end
  end
end
