require 'zxing'
require 'pathname'
require 'image_voodoo'
require './card'

folder = ARGV[0]
puts "Looking for scanned images in #{folder}"
path = Pathname.new(folder)

Dir["#{folder}/*.jpg"].each do |fn|
    puts fn
    # Home in on the QRCode to help with reading it
    ImageVoodoo.with_image(fn) do |img|
        img.with_crop(200, 1880, 600, 2280) do |img2|
            img2.rotate(270).save "temp_qr.png"
        end
    end
    # Read QR
    class_and_name = ZXing.decode "temp_qr.png"
    if !class_and_name.nil?
        splat = class_and_name.split(':')
        if splat.length == 2
            @class_group = class_and_name.split(':')[0]
            @child_name = class_and_name.split(':')[1]
            # cut out artwork and save in cutouts/
            ImageVoodoo.with_image(fn) do |img|
                img.with_crop(875, 135, 3055, 2325) do |img2|
                    @artfile = "cutouts/#{@class_group} #{@child_name}.png"
                    img2.rotate(270).save @artfile
                end
            end
            # make card and save in cards/
            pdf = Card.new(@artfile, @child_name, @class_group)
            pdf.render_file "cards/#{@class_group} #{@child_name}.pdf"
        else
            puts "#{fn} - could not split QRCode on colon."
        end
    else
        puts "#{fn} - could not read QRCode."
    end
end