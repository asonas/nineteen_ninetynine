module NineteenNinetynine
  module Img2cat
    def executable_img2cat_command
      @executable_img2cat_command ||= nil
    end

    def determine_img2cat_command
      # TODO: use exit code, supressess STDOUT
      if system("which", "wezterm")
        @executable_img2cat_command = "wezterm imgcat"
      elsif system("which", "imgcat")
        @executable_img2cat_command = "imgcat"
      elsif system("which", "img2sixel")
        @executable_img2cat_command = "img2sixel"
      end
    end
  end
end
