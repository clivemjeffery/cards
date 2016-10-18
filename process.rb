require 'zxing'
fn = ARGV[0]
puts "#{fn} contains the qrcode for:"
puts ZXing.decode fn