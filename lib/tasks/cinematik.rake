namespace :cinematik do

  desc "Scrapes the events from Cinematik web and stores them in DB"
  task :scrape_events => :environment do
    require 'wombat'

    puts "Scraping the web for events..."
    data = Wombat.crawl do
      base_url "http://www.cinematik.sk"
      path "/program/"

      program 'css=h2.grid-tit a', :follow do
        name 'css=div.grid-text h1'
        original_name 'xpath=//div[@class="movie_meta"][1]//h2[1]'
        date 'xpath=//div[@class="projekcia"][1]//ul[1]//li[1]'
        time 'xpath=//div[@class="projekcia"][1]//ul[1]//li[2]'
        place 'xpath=//div[@class="projekcia"][1]//ul[1]//li[3]'
        section 'xpath=//div[@class="sekcia"][1]//strong[1]/a[1]'
        director 'xpath=//div[@class="movie_meta"][1]//p[2]//strong'
        meta 'xpath=//div[@class="movie_meta"][1]//p[@class="gray"][1]'
      end
    end

    puts "Truncating tables: events"
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE events")

    puts "Storing the events in the DB..."
    data['program'].each do |event|
      if event['date'] && event['time'] && event['place']
        Event.find_or_create_by(name: event['name']) do |e|
          e.original_name = event['original_name']
          e.date = (event['date'].gsub!(/[^\d\.]/, '') + "2014 #{event['time']}").to_datetime
          e.place = event['place']
          e.section = event['section']
          e.director = event['director']
          e.meta = event['meta']
        end
        puts "created event: #{event['name']}"
      end
    end
  end
end