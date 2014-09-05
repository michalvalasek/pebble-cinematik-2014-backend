namespace :cinematik do

  desc "Scrapes the events from Cinematik web and stores them in DB"
  task :scrape_events => :environment do
    require 'Wombat'

    puts "Scraping the web for events..."
    data = Wombat.crawl do
      base_url "http://www.cinematik.sk"
      path "/program/"

      program 'css=h2.grid-tit a', :follow do
        name 'css=div.grid-text h1'
        date 'xpath=//div[@class="projekcia"][1]//ul[1]//li[1]'
        time 'xpath=//div[@class="projekcia"][1]//ul[1]//li[2]'
        place 'xpath=//div[@class="projekcia"][1]//ul[1]//li[3]'
      end
    end

    puts "Truncating tables: events"
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE events")

    puts "Storing the events in the DB..."
    data['program'].each do |event|
      if event['date'] && event['time'] && event['place']
        Event.find_or_create_by(name: event['name']) do |e|
          e.date = (event['date'].gsub!(/[^\d\.]/, '') + "2014 #{event['time']}").to_datetime
          e.place = event['place']
        end
        puts "created event: #{event['name']}"
      end
    end
  end
end