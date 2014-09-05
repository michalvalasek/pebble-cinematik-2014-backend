class Event < ActiveRecord::Base

  def day
    days = %w(Nedela Pondelok Utorok Streda Stvrtok Piatok Sobota)
    days[self.date.wday]
  end

  def time
    minutes = "%02d" % self.date.min
    "#{self.date.hour}:#{minutes}"
  end
end
