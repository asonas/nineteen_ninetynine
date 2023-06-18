module NineteenNinetynine
  class Renderer
    attr_accessor :receiver
    def initialize
      DRb.start_service
      @receiver = DRbObject.new_with_uri(NineteenNinetynine::DRB_UNIX_SOCKET)
    end

    def output
      @receiver.start
      @receiver.items.each do |item|
        puts item
      end
    end
  end
end
