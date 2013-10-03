#!/usr/bin/env ruby
#
# Convert blogger (blogspot) posts to jekyll posts
#
# Basic Usage
# -----------
#
#   ./blogger_to_jekyll.rb feed_url
#
#  where `feed_url` can have the following format:
#
#  http://{your_blog_name}.blogspot.com/feeds/posts/default
#
# Requirements
# ------------
# 
#  * feedzirra: https://github.com/pauldix/feedzirra
#
# Notes
# -----
#
#  * Make sure Blogger shows full output of article in feeds.
#  * Commenting on migrated articles will be set to false by default.

include RbConfig

require 'rubygems' if CONFIG['host_os'].start_with? "darwin"
require 'feedzirra'
require 'date'
require 'optparse'

def parse_post_entries(feed, verbose)
  posts = []
  feed.entries.reverse.each do |post|
    obj = Hash.new
    created_datetime = post.updated
    creation_date = Date.parse(created_datetime.to_s)
    title = post.title
    file_name = creation_date.to_s + "-" + title.delete("'").delete('.').delete(',').delete('-').downcase.split(/  */).join("-").delete('\/') + ".html"
    # specials

    puts "filename #{file_name}"
    file_name.sub!('climb-in-the-vineyards','climb-in-vineyards')
    file_name.sub!('russin-looking-over-the-vally','russin-looking-over-vally')
    file_name.sub!('next-to-the-auberge-in-satigny','next-to-auberge-in-satigny')
    file_name.sub!('castle-at-st-genis','castle-in-st-genis')
    file_name.sub!('panoramic-climbing-at-challex','panoramic-climbing-frame-at-challex')
    file_name.sub!('table-football-and-skateboard-park-at-moëns','table-football-and-skateboard-park-at')
    file_name.sub!('lunching-and-climbing-at-the-chavannes-centre','lunching-and-climbing-at-chavannes')
    file_name.sub!('the-tractor-at-commugny','tractor-at-commugny')
    file_name.sub!('10-19-funny-man-in-meyrin','09-19-funny-man-in-meyrin')
    file_name.sub!('the-lizard-of-the-jardin-botanique','lizard-of-jardin-botanique')
    file_name.sub!('2010-11-01-parc-des-bastions','2010-10-01-parc-des-bastions')
    file_name.sub!('springy-bullrushes-at-parc-de-mon-repos','springy-bull-rushes-at-parc-de-mon')
    file_name.sub!('fly-the-plane-in-petitsaconnex','fly-plane-in-petit-saconnex')
    file_name.sub!('the-icosikaioctagon-at-boisdelabâtie','icosikaioctagon-at-bois-de-la-batie')
    file_name.sub!('view-mt-blanc-while-climbing-on-salève','view-mt-blanc-while-climbing-on-saleve')
    file_name.sub!('2011-05-05-ahoy-on-a-sea-of-sand-in-nyon','2010-10-05-ahoy-on-sea-of-sand-in-nyon')
    file_name.sub!('2011-05-05-buvette-on-the-lake-at-versoix','2010-10-05-buvette-on-lake-at-versoix')
    file_name.sub!('2011-05-05-by-the-lake-at-nyon','2010-10-05-by-lake-at-nyon')
    file_name.sub!('on-the-lake-in-pregny-along-from-jardin-botanique','on-lake-in-pregny-along-from-jardin')
    file_name.sub!('2013-07-11-the-secret-playground-in-sergy','2010-09-11-the-secret-playground-in-sergy')
    file_name.sub!('2012-09-24-pizza-on-the-terrace-in-st-genis','2010-09-24-pizza-on-the-terrace-in-st-genis')
    file_name.sub!('climbing-at-a-campsite-near-seleve','climbing-at-campsite-near-seleve')
    file_name.sub!('the-tall-ship-of-lausanne','tall-ship-of-lausanne')
    file_name.sub!('2011-11-13-bouncy-castles-at-palexpo','2011-01-13-bouncy-castles-at-palexpo')
    file_name.sub!('the-tram-at-confort','tram-at-confort')
    file_name.sub!('2011-09-01-the-woods-in-argentière','2011-05-01-woods-in-argentiere')
    file_name.sub!('the-immaculate-plage-at-hemance','emaculate-plage-at-hemance')
    file_name.sub!('the-tower-at-chancy','tower-at-chancy')
    file_name.sub!('2011-05-16-mclhcb-near-ferney','2011-04-16-mclhcb-near-ferney')
    file_name.sub!('2010-09-24-pizza-on-the-terrace-in-st-genis','2010-10-24-pizza-on-terrace-in-st-genis')

    content = post.content
    
    obj["file_name"] = file_name
    obj["title"] = title
    obj["creation_datetime"] = created_datetime
    obj["updated_datetime"] = post.updated
    obj["content"] = content
    obj["categories"] = post.categories.join(" ")
    posts.push(obj)
  end
  return posts
end

def write_posts(posts, verbose)
  Dir.mkdir("_posts") unless File.directory?("_posts")

  total = posts.length, i = 1
  posts.each do |post|
    file_name = "_posts/".concat(post["file_name"])
    header = %{---           
layout: post
title: #{post["title"]}
date: #{post["creation_datetime"]}
updated: #{post["updated_datetime"]}
comments: false
categories: #{post["categories"]}
---

}
    File.open(file_name, "w+") {|f|
      f.write(header)
      f.write(post["content"])
      f.close
    }
    
    if verbose
      puts "  [#{i}/#{total[0]}] Written post #{file_name}"
      i += 1
    end
  end
end

def main
  options = {}
  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: ./blogger_to_jekyll.rb FEED_URL [OPTIONS]"
    opt.separator ""
    opt.separator "Options"
    
    opt.on("-v", "--verbose", "Print out all.") do
      options[:verbose] = true
    end
  end

  opt_parser.parse!
  
  if ARGV[0]
    feed_url = ARGV.first
  else
    puts opt_parser
    exit()
  end

  puts "Fetching feed #{feed_url}..."
  feed = Feedzirra::Feed.fetch_and_parse(feed_url)
  
  puts "Parsing feed..."
  posts = parse_post_entries(feed, options[:verbose])
  
  puts "Writing posts to _posts/..."
  write_posts(posts, options[:verbose])

  puts "Done!"
end

main()
