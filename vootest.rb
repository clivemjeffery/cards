require 'image_voodoo'
ImageVoodoo.with_image(ARGV[0]) do |img|
    img.with_crop(600, 100, 2000, 1500) do |img2|
    	img2.rotate(270).save "voocard.jpg"
    end
end