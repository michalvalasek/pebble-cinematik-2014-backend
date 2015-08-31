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
        people 'xpath=//div[@class="movie_meta"]//p[3]'
        description 'xpath=//div[@class="grid-text"]//div[@class="row"]//div[@class="col-md-6"][1]//p'
      end
    end

    puts "Truncating tables: events"
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE events RESTART IDENTITY")

    puts "Storing the events in the DB..."
    current_year = Date.today.year.to_s
    data['program'].each do |event|
      if event['date'] && event['time'] && event['place']
        Event.find_or_create_by(name: event['name']) do |e|
          e.original_name = event['original_name']
          e.date = (event['date'].gsub!(/[^\d\.]/, '') + current_year + " #{event['time']}").to_datetime
          e.place = event['place']
          e.section = event['section']
          e.director = event['director']
          e.meta = event['meta'].gsub(/[\t\n]/,'') if event['meta']
          e.people = event['people'].gsub(/<\/?span(\sclass="gray")?>/,'').gsub(/<\/?strong>/, '').gsub(/\s+/,' ')
          e.description = event['description']
        end
        puts "created event: #{event['name']}"
      end
    end
  end

  namespace :pebble do
    require 'pebble_timeline'
    PebbleTimeline.config.api_key = ENV['PEBBLE_API_KEY']
    @pins = PebbleTimeline::Pins.new

    desc "Pushes Pebble Timeline pins to the Pebble API"
    task :push_pins => :environment do
      Event.upcoming.each do |event|
        pin = {
          id: "cinematik-#{event.id}",
          time: event.date.to_time.iso8601,
          topics: 'cinematik',
          layout: {
            type: 'genericPin',
            title: event.name,
            shortTitle: event.name,
            subtitle: event.place,
            tinyIcon: 'system://images/MOVIE_EVENT',
            headings: ["Original name","Section","Director","Meta"],
            paragraphs: [
              event.original_name,
              event.section,
              event.director,
              event.meta
            ]
          }
        }

        duration = event.meta.scan(/(\d+)\s?min/)
        if duration.size>0
          pin[:duration] = duration.first.first.to_i
        end

        print "Pushing '#{event.name}'... "
        puts @pins.create(pin)
      end
    end

    desc "Deletes pins of all upcoming events"
    task :delete_pins => :environment do
      if last_id = Event.all.last.id
        range = (1..last_id)
        puts "Deleting #{range.count} pins..."
        range.each do |id|
          @pins.delete("cinematik-#{id}")
        end
      end
    end

    task :push_test_pin => :environment do
      event = Event.all.last
      pin = {
        id: "cinematik-#{event.id}",
        time: (Time.now + 4.hour).iso8601,
        topics: 'cinematik',
        layout: {
          type: 'genericPin',
          title: event.name,
          shortTitle: event.name,
          subtitle: event.place,
          tinyIcon: 'system://images/MOVIE_EVENT',
          headings: ["Original name","Section","Director","Meta"],
          paragraphs: [
            event.original_name,
            event.section,
            event.director,
            event.meta
          ]
        }
      }

      duration = event.meta.scan(/(\d+)\s?min/)
      if duration.size>0
        pin[:duration] = duration.first.first.to_i
      end

      print "Pushing testing pin: '#{event.name}' @ #{pin[:time]}... "
      puts @pins.create(pin)
    end
  end
end
