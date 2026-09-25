require "nokogiri"
require "pathname"
require "uri"
require "yaml"

root = Pathname.new(__dir__).parent
site = root.join("_site")
config = YAML.safe_load(root.join("_config.yml").read)
baseurl = config.fetch("baseurl")
origin = config.fetch("url") + baseurl
pages = site.glob("**/*.html").to_h { |path| [path, Nokogiri::HTML(path.read)] }
abort "Build the site before running this check." if pages.empty?

errors = []
pages.each do |path, page|
  name = path.relative_path_from(site)
  canonical = page.at_css('link[rel="canonical"]')&.[]("href")
  errors << "#{name}: incorrect canonical URL" unless canonical&.start_with?(origin + "/")
  %w[og:description og:image].each do |property|
    value = page.at_css("meta[property='#{property}']")&.[]("content")
    errors << "#{name}: missing #{property}" if value.to_s.empty?
  end

  previous = 0
  page.css("h1,h2,h3,h4,h5,h6").each do |heading|
    level = heading.name[1].to_i
    errors << "#{name}: heading skips from H#{previous} to H#{level}" if level > previous + 1
    previous = level
  end

  page.css("a[href],link[href],script[src],img[src]").each do |element|
    reference = element["href"] || element["src"]
    uri = URI.parse(reference)
    next if uri.scheme || uri.host

    relative = URI::DEFAULT_PARSER.unescape(uri.path.to_s)
    target = if relative.empty?
               path
             elsif relative.start_with?("/")
               site.join(relative.delete_prefix(baseurl).delete_prefix("/"))
             else
               path.parent.join(relative).cleanpath
             end
    target = [target, target.join("index.html"), Pathname.new("#{target}.html")].find(&:file?)
    if target.nil?
      errors << "#{name}: missing target #{reference}"
    elsif uri.fragment && pages[target]
      fragment = URI::DEFAULT_PARSER.unescape(uri.fragment)
      errors << "#{name}: missing anchor #{reference}" unless pages[target].css("[id]").any? { |node| node["id"] == fragment }
    end
  end
end

abort errors.join("\n") unless errors.empty?
puts "Checked #{pages.size} pages: links, assets, heading order, and search metadata pass."
