module NineteenNinetynine
  class Event
    class Profile
      attr_accessor :name, :pubkey, :icon_image_url, :raw


      def initialize
        @name = nil
        @pubkey = nil
        @icon_image_url = nil
      end

      def download_icon_image
        return nil if @icon_image.nil?
        url = URL.parse @icon_image_url
        pathname = Pathname.new(url.path)

        File.write("icon_image.png", @icon_image.download)
        @icon_image.download
      end
    end
  end
end
