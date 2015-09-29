module RoomsHelper
  def to_duration(secs)
    ## Display in time duration format 1h25'34"
    h = secs / 3600;      # hours
    m = secs % 3600 / 60; # minutes
    s = secs % 3600 % 60; # seconds
    return "#{format('%02d', h)}:#{format('%02d', m)}:#{format('%02d', s)}"
  end
end
