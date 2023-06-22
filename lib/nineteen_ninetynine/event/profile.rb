module NineteenNinetynine
  class Event
    class Profile
      attr_accessor :name, :pubkey, :raw, :icon_path, :icon_io

      def initialize(event)
        @raw = event

        @pubkey = event["pubkey"]
        content = JSON.parse(event["content"])
        @name = content["name"]
        @picture_url = content["picture"]
        set_icon

        if !@picture_url.nil? && !@picture_url.empty?
          unless File.exist?(icon_path)
            Thread.start do
              download_icon_image
            end
          end
        end
      end

      def set_icon
        if File.exist? icon_path
          @icon_path = icon_path
        else
          @icon_path = icon_dir + "/default.png"
        end
      end

      def icon_path
        "#{icon_dir}/#{@pubkey}"
      end

      def icon_dir
        "#{XDG_CONFIG_DIR}/icons"
      end

      def icon
        `wezterm imgcat --height 1 #{@icon_path}`.strip
      end

      def download_icon_image
        if @picture_url.start_with?("data:image/")
          File.write(icon_path, Base64.decode64(@picture_url.split(",")[1]))
        elsif @picture_url.start_with?("http")
          url = URI.parse @picture_url
          begin
          res = Net::HTTP.get_response(url)
          case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            File.write(icon_path, res.body)
          when Net::HTTPClientError, Net::HTTPServerError
            # ignore
          else
            puts "unknown"
            puts @picture_url
          end
        rescue SocketError, Net::OpenTimeout => e
          # ignore
        end
        else
          puts "Unknown schema"
          puts @picture_url
        end
      end
    end
  end
end
