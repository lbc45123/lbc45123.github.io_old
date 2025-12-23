require 'feedjira'
require 'httparty'
require 'jekyll'
require 'nokogiri'
require 'time'

module ExternalPosts
  class ExternalPostsGenerator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      if site.config['external_sources'] != nil
        site.config['external_sources'].each do |src|
          puts "Fetching external posts from #{src['name']}:"
          if src['rss_url']
            fetch_from_rss(site, src)
          end
          if src['posts']
            fetch_from_urls(site, src)
          end
        end
      end
    end

    def fetch_from_rss(site, src)
      xml = HTTParty.get(src['rss_url']).body
      return if xml.nil?
      begin
        feed = Feedjira.parse(xml)
      rescue StandardError => e
        puts "Error parsing RSS feed from #{src['rss_url']} - #{e.message}"
        return
      end
      process_entries(site, src, feed.entries)
    end

    def process_entries(site, src, entries)
      entries.each do |e|
        puts "...fetching #{e.url}"
        create_document(site, src, e.url, {
          title: e.title,
          content: e.content,
          summary: e.summary,
          published: e.published
        })
      end
    end

    def create_document(site, src, url, content)
      source_name = src['name']
      
      # Clean LaTeX-style formatting from title
      title = content[:title].dup
      title.gsub!(/\\uppercase\{([^}]*)\}/) { $1.upcase }
      title.gsub!(/\\textbf\{([^}]*)\}/, '<b>\1</b>')
      title.gsub!(/\\textsuperscript\{([^}]*)\}/, '<sup>\1</sup>')
      title.gsub!(/\\textit\{([^}]*)\}/, '<i>\1</i>')
      title.gsub!(/\\href\{[^}]*\}\{([^}]*)\}/, '\1') # Strip href from title if any

      # check if title is composed only of whitespace or foreign characters
      if title.gsub(/[^\w]/, '').strip.empty?
        # use the source name and last url segment as fallback
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}"
      else
        # parse title from the post or use the source name and last url segment as fallback
        slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        slug = "#{source_name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}-#{url.split('/').last}" if slug.empty?
      end

      path = site.in_source_dir("_posts/#{slug}.md")
      doc = Jekyll::Document.new(
        path, { :site => site, :collection => site.collections['posts'] }
      )
      doc.data['external_source'] = source_name
      doc.data['title'] = title
      doc.data['feed_content'] = content[:content]
      doc.data['description'] = content[:summary]
      doc.data['date'] = content[:published]
      doc.data['redirect'] = url
      doc.data['thumbnail'] = src['image'] if src['image']
      doc.data['tags'] = content[:tags] if content[:tags]
      doc.data['categories'] = content[:categories] if content[:categories]
      doc.content = content[:content]
      site.collections['posts'].docs << doc
    end

    def fetch_from_urls(site, src)
      src['posts'].each do |post|
        puts "...fetching #{post['url']}"
        content = fetch_content_from_url(post['url'])
        content[:published] = parse_published_date(post['published_date'])
        # Allow overriding the summary from config
        content[:summary] = post['summary'] if post['summary']
        # Pass tags and categories
        content[:tags] = post['tags']
        content[:categories] = post['categories']
        create_document(site, src, post['url'], content)
      end
    end

    def parse_published_date(published_date)
      case published_date
      when String
        Time.parse(published_date).utc
      when Date
        published_date.to_time.utc
      else
        raise "Invalid date format for #{published_date}"
      end
    end

    def fetch_content_from_url(url)
      html = HTTParty.get(url).body
      parsed_html = Nokogiri::HTML(html)

      full_title = parsed_html.at('head title')&.text.strip || ''
      
      # Keep "Title | Source" but remove middle " | by Author" part
      # Logic: Take part before first '|' and part after last '|'
      if full_title.include?('|')
        parts = full_title.split('|').map(&:strip)
        title = "#{parts.first} | #{parts.last}"
      else
        title = full_title
      end

      description = parsed_html.at('head meta[name="description"]')&.attr('content')
      description ||= parsed_html.at('head meta[name="og:description"]')&.attr('content')
      description ||= parsed_html.at('head meta[property="og:description"]')&.attr('content')

      body_content = parsed_html.search('p').map { |e| e.text }
      body_content = body_content.join() || ''

      {
        title: title,
        content: body_content,
        summary: description
        # Note: The published date is now added in the fetch_from_urls method.
      }
    end

  end
end
