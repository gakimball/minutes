module Util
  def self.reading_time(length, wpm = 250) # Average reading WPM according to wiki
    length.to_f / wpm.to_f
  end

  def self.minutes_to_string(minutes)
    secs = (minutes % 1) * 60
    minutes = minutes.floor
    secs = secs.floor

    time_str = ""
    if minutes > 0
      time_str += "#{minutes} minutes"
    end

    if minutes > 0 and secs > 0
      time_str += ", "
    end

    if secs > 0
      time_str += "#{secs} seconds"
    end
    
    time_str
  end

  def self.minutes_to_clock_string(minutes)
    secs = (minutes % 1) * 60
    minutes = minutes.floor
    secs = format('%02d', secs.floor)

    "#{minutes}:#{secs}"
  end
end