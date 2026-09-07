#!/usr/bin/ruby
# Convert an 8-bit, non-interlaced RGBA PNG to opaque RGB without lossy JPEG.

require "zlib"

SIGNATURE = "\x89PNG\r\n\x1a\n".b
KEEP_CHUNKS = %w[cHRM gAMA iCCP sRGB pHYs tEXt zTXt iTXt].freeze

def fail!(message)
  warn "PNG_COMPAT_RGB_FAILED: #{message}"
  exit 1
end

def paeth(a, b, c)
  p = a + b - c
  pa = (p - a).abs
  pb = (p - b).abs
  pc = (p - c).abs
  return a if pa <= pb && pa <= pc
  return b if pb <= pc

  c
end

def chunk(type, payload)
  bytes = type.b + payload
  [payload.bytesize].pack("N") + bytes + [Zlib.crc32(bytes)].pack("N")
end

input, output = ARGV
fail!("usage: png_opaque_rgb.rb INPUT OUTPUT") unless input && output

png = File.binread(input)
fail!("bad signature") unless png.start_with?(SIGNATURE)

offset = SIGNATURE.bytesize
ihdr = nil
idat = +"".b
kept = []

while offset + 12 <= png.bytesize
  length = png.byteslice(offset, 4).unpack1("N")
  type = png.byteslice(offset + 4, 4)
  payload = png.byteslice(offset + 8, length)
  fail!("truncated #{type}") unless payload && payload.bytesize == length
  case type
  when "IHDR" then ihdr = payload
  when "IDAT" then idat << payload
  else kept << [type, payload] if KEEP_CHUNKS.include?(type)
  end
  offset += length + 12
  break if type == "IEND"
end

fail!("missing IHDR or IDAT") unless ihdr && !idat.empty?
width, height, depth, color_type, compression, filter_method, interlace =
  ihdr.unpack("NNCCCCC")
fail!("unsupported bit depth #{depth}") unless depth == 8
fail!("unsupported color type #{color_type}") unless color_type == 6
fail!("unsupported PNG methods") unless compression.zero? && filter_method.zero? && interlace.zero?

row_bytes = width * 4
inflated = Zlib::Inflate.inflate(idat)
expected = height * (row_bytes + 1)
fail!("unexpected raster bytes #{inflated.bytesize}/#{expected}") unless inflated.bytesize == expected

previous = Array.new(row_bytes, 0)
rgb_rows = +"".b
cursor = 0

height.times do
  filter = inflated.getbyte(cursor)
  cursor += 1
  encoded = inflated.byteslice(cursor, row_bytes).bytes
  cursor += row_bytes
  decoded = Array.new(row_bytes, 0)

  row_bytes.times do |index|
    left = index >= 4 ? decoded[index - 4] : 0
    up = previous[index]
    upper_left = index >= 4 ? previous[index - 4] : 0
    predictor = case filter
                when 0 then 0
                when 1 then left
                when 2 then up
                when 3 then (left + up) / 2
                when 4 then paeth(left, up, upper_left)
                else fail!("unsupported row filter #{filter}")
                end
    decoded[index] = (encoded[index] + predictor) & 0xff
  end

  rgb_rows << "\x00"
  decoded.each_slice(4) do |red, green, blue, alpha|
    rgb_rows << ((red * alpha + 255 * (255 - alpha) + 127) / 255).chr
    rgb_rows << ((green * alpha + 255 * (255 - alpha) + 127) / 255).chr
    rgb_rows << ((blue * alpha + 255 * (255 - alpha) + 127) / 255).chr
  end
  previous = decoded
end

rgb_ihdr = [width, height, 8, 2, 0, 0, 0].pack("NNCCCCC")
result = +SIGNATURE
result << chunk("IHDR", rgb_ihdr)
kept.each { |type, payload| result << chunk(type, payload) }
result << chunk("IDAT", Zlib::Deflate.deflate(rgb_rows, Zlib::BEST_COMPRESSION))
result << chunk("IEND", "".b)

temporary = "#{output}.#{Process.pid}.tmp"
File.binwrite(temporary, result)
File.rename(temporary, output)
puts "PNG_COMPAT_RGB_OK out=#{output} bytes=#{result.bytesize}"
