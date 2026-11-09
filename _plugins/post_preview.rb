require "base64"
require "digest"
require "fileutils"
require "nokogiri"

module Jekyll
  # Notebook figures are usually embedded data URLs. Write just the selected
  # figure as a normal asset so the index does not duplicate notebook payloads.
  class PreviewFigure < StaticFile
    def initialize(site, name, bytes)
      super(site, site.source, "assets/post-previews", name)
      @bytes = bytes
    end

    def write(dest)
      target = destination(dest)
      FileUtils.mkdir_p(File.dirname(target))
      File.binwrite(target, @bytes)
      true
    end
  end

  module PostPreview
    def self.select(post)
      return if post.data["hide"] == true

      settings = (post.site.data["post_previews"] || {})[post.basename_without_ext] || {}
      explicit = post.data["image"] || settings["image"]
      explicit = explicit["path"] if explicit.is_a?(Hash)
      alt = settings["alt"] || post.data["image_alt"] || ""
      if explicit && !explicit.empty?
        post.data["index_preview"] = { "src" => explicit, "alt" => alt }
        return
      end

      document = Nokogiri::HTML(post.output)
      figures = document.css(".post-content img").reject do |img|
        img["src"].to_s.empty? || img["class"].to_s.split.include?("emoji") ||
          img["src"].match?(%r{(?:/badges/|shields\.io|badge\.svg)}) ||
          (img["width"] && img["width"].to_i.between?(1, 64)) ||
          (img["height"] && img["height"].to_i.between?(1, 64))
      end
      figure = figures[settings.fetch("figure", 0)] || figures.first
      return unless figure

      src = figure["src"]
      if (match = src.match(%r{\Adata:image/(png|jpeg|gif|webp);base64,(.+)\z}m))
        bytes = Base64.strict_decode64(match[2].gsub(/\s+/, ""))
        name = "#{Digest::SHA256.hexdigest(bytes)[0, 20]}.#{match[1]}"
        post.site.static_files << PreviewFigure.new(post.site, name, bytes)
        src = "/assets/post-previews/#{name}"
      elsif src.start_with?("data:")
        return
      else
        # Browser-relative image paths must resolve against the post, not home.
        unless src.match?(%r{\A(?:https?:)?/})
          src = File.expand_path(src, File.dirname(post.url))
        end
        baseurl = post.site.baseurl.to_s
        src = src.delete_prefix(baseurl) if !baseurl.empty? && src.start_with?("#{baseurl}/")
      end
      post.data["index_preview"] = { "src" => src, "alt" => alt.empty? ? figure["alt"].to_s : alt }
    rescue ArgumentError => error
      Jekyll.logger.warn "Post preview:", "#{post.relative_path}: #{error.message}"
    end
  end
end

# Jekyll renders documents before pages, so these figures are ready for home.
Jekyll::Hooks.register :posts, :post_render do |post|
  Jekyll::PostPreview.select(post)
end
