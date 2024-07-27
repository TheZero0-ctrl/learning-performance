# frozen_string_literal: true

def radian_from_degrees(degrees)
  0.01745329251994329577 * degrees
end

def sin(x)
  Math.sin(x)
end

def cos(x)
  Math.cos(x)
end

def square(x)
  x * x
end

def sqrt(x)
  Math.sqrt(x)
end

def atan2(y, x)
  Math.atan2(y, x)
end

def reference_haversine(x0, y0, x1, y1, earth_radius = 6372.8)
  lat1 = y0
  lat2 = y1
  lon1 = x0
  lon2 = x1
  dlat = radian_from_degrees(lat2 - lat1)
  dlon = radian_from_degrees(lon2 - lon1)

  a = square(sin(dlat / 2.0)) + cos(radian_from_degrees(lat1)) * cos(radian_from_degrees(lat2)) * square(sin(dlon / 2.0))
  c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
  earth_radius * c
end
