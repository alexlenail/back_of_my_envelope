require "minitest/autorun"
require "tmpdir"
require "jekyll"
require_relative "../_plugins/post_preview"

class PostPreviewTest < Minitest::Test
  Site = Struct.new(:source, :data, :static_files, :baseurl) do
    def in_dest_dir(*paths)
      File.join(*paths)
    end
  end
  Post = Struct.new(:site, :data, :output, :basename_without_ext, :url)

  def setup
    @site = Site.new(Dir.tmpdir, {}, [], "/blog")
    @post = Post.new(@site, {}, "", "example", "/2021/05/18/example.html")
  end

  def select(html)
    @post.output = '<div class="post-content">' + html + '</div>'
    Jekyll::PostPreview.select(@post)
    @post.data["index_preview"]
  end

  def test_embedded_figure_is_written_as_a_separate_asset
    bytes = "notebook figure bytes"
    preview = select('<img src="data:image/png;base64,' + Base64.strict_encode64(bytes) + '" alt="A plot">')
    assert_equal "A plot", preview["alt"]
    assert_match %r{\A/assets/post-previews/\w+\.png\z}, preview["src"]
    Dir.mktmpdir do |dir|
      @site.static_files.first.write(dir)
      assert_equal bytes, File.binread(File.join(dir, preview["src"]))
    end
  end

  def test_skips_badges_and_emoji
    preview = select('<img class="emoji" src="/emoji.png"><img src="https://shields.io/badge.svg"><img src="/plot.png">')
    assert_equal "/plot.png", preview["src"]
  end

  def test_curated_selection_and_alt_text
    @site.data["post_previews"] = { "example" => { "figure" => 1, "alt" => "Selected plot" } }
    preview = select('<img src="/first.png"><img src="/second.png">')
    assert_equal({ "src" => "/second.png", "alt" => "Selected plot" }, preview)
  end

  def test_front_matter_overrides_curated_image
    @site.data["post_previews"] = { "example" => { "image" => "/curated.png" } }
    @post.data["image"] = { "path" => "/chosen.png" }
    assert_equal "/chosen.png", select("")["src"]
  end

  def test_resolves_relative_urls_and_removes_existing_baseurl
    assert_equal "/2021/05/figures/plot.png", select('<img src="../figures/plot.png">')["src"]
    assert_equal "/figures/plot.png", select('<img src="/blog/figures/plot.png">')["src"]
    assert_equal "https://example.com/plot.png", select('<img src="https://example.com/plot.png">')["src"]
  end

  def test_missing_figures_and_hidden_posts_have_no_preview
    assert_nil select("<p>No static figures.</p>")
    @post.data["hide"] = true
    assert_nil select('<img src="/plot.png">')
    assert_empty @site.static_files
  end
end
