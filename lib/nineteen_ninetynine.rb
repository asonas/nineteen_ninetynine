# frozen_string_literal: true

require_relative "nineteen_ninetynine/version"

require_relative "nineteen_ninetynine/core"
require_relative "nineteen_ninetynine/ext"
require_relative "nineteen_ninetynine/renderer"
require_relative "nineteen_ninetynine/id_var"
require_relative "nineteen_ninetynine/img2cat"
require_relative "nineteen_ninetynine/initializer"
require_relative "nineteen_ninetynine/output"
require_relative "nineteen_ninetynine/subscriber"
require_relative "nineteen_ninetynine/event/note"
require_relative "nineteen_ninetynine/event/profile"
require_relative "nineteen_ninetynine/utils"

require "active_support/cache"
require "active_support/notifications"
require "eventmachine"
require "fileutils"
require "json"
require "monitor"
require "net/http"
require "readline"
require "stringio"
require "thread"
require "uri"

module NineteenNinetynine
  extend Core
  extend Initializer
  extend Renderer
  extend Output
  extend IdVar
  extend Img2cat

  User = Data.define :name, :pubkey

  class Error < StandardError; end
  XDG_CONFIG_DIR = "#{ENV['HOME']}/.config/1999"
  @users = []
  @items = []

  unless Dir.exist?(XDG_CONFIG_DIR)
    FileUtils.mkdir_p(XDG_CONFIG_DIR)
    FileUtils.mkdir_p(XDG_CONFIG_DIR + "/icons")
  end
  FileUtils.cp(File.dirname(__FILE__) + "/assets/default.png", XDG_CONFIG_DIR + "/icons/default.png")

  init do
    determine_img2cat_command
    self.id_var ||= IdVar::Gen.new
    outputs.clear
    output_filters.clear
    config = {}

    config[:colors] ||= (31..36).to_a + (91..96).to_a
    config[:color] ||= {}
    config[:color].merge!(
      info:   90,
      notice: 31,
      event:  42,
      url:    [4, 36],
    )
    config[:raw_text] ||= true

    output :note do |item|
      info = []

      id = id2var(item.sig)

      text = item.body

      if /\n/ =~ text
        text.prepend("\n")
        text.gsub!(/\n/, "\n          " + "|".c(:info))
        text << "\n      "
      else
        text.gsub!(/\s+/, ' ')
      end
      text = text.coloring(/@[0-9A-Za-z_]+/) { |i| color_of(i) }
      text = text.coloring(/(^#[^\s]+)|(\s+#[^\s]+)/) { |i| color_of(i) }
      # if config[:expand_url]
      #   entities = (item["retweeted_status"] && item["truncated"]) ? item["retweeted_status"]["entities"] : item["entities"]
      #   if entities
      #     entities.values_at("urls", "media").flatten.compact.each do |entity|
      #       url, expanded_url = entity.values_at("url", "expanded_url")
      #       if url && expanded_url
      #         text = text.sub(url, expanded_url)
      #       end
      #     end
      #   end
      # end
      text = text.coloring(URI.regexp(["http", "https"]), :url)

      # if item["_highlights"]
      #   item["_highlights"].each do |h|
      #     color = config[:color][:highlight].nil? ? color_of(h).to_i + 10 : :highlight
      #     text = text.coloring(/#{h}/i, color)
      #   end
      # end

      mark = item._mark || ""
      icon = `#{@executable_img2cat_command} --height 1 #{item.user.icon_path}`.strip

      status = [
        item.date.strftime("%H:%M").c(:info),
        mark + id.c(:info),
        "#{icon}#{item.user.name.c(color_of(item.user.name))}:",
        text,
        info.join(' - ').c(:info),
      ].compact.join(" ")
      puts status
    end
  end
end
