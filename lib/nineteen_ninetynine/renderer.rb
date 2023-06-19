module NineteenNinetynine
  class Renderer
    attr_accessor :items, :users, :item_queue, :loaded

    def initialize
      @items = []
      @users = []
      @loaded = false
      @item_queue = []
    end

    def output
      while item = item_queue.shift
        if item.user.nil?
          user = @users.find { |u| u.pubkey == item.raw["pubkey"] }
          item.user = user
        end
        puts item.decorate
      end
    end

    def puts_items(item)
    end

    def insert
    end
  end
end
