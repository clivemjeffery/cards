require 'rqrcode'
qrcode = RQRCode::QRCode.new("http://github.com/")
# With default options specified explicitly
png = qrcode.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 120,
          border_modules: 4,
          module_px_size: 6,
          file: nil # path to write
          )
IO.write("qrcode.png", png.to_s)