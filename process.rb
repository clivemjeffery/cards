require 'zxing'
require 'pathname'
require 'fileutils'
require 'image_voodoo'
require './card'

@source = ARGV[0] # single filename or folder to scan
@dest = ARGV[1] # destination folder
@class_group = ARGV[2] # override class on command line - no qr scan
@child_name = ARGV[3] # override name of command line - no qr scan


destpath = Pathname.new(@dest)
if !Dir.exist?(destpath)
	puts "Making output folder #{@dest}"
	Dir.mkdir(@dest)
end

def readQRcodes(fn)
	temp_qrcode1_filename = "temp_process_code1.png"
	temp_qrcode2_filename = "temp_process_code2.png"
	failed_scans_folder = "#{@source}/failed_scans/"
    base = Pathname.new(fn).basename
	
	# Home in on the QRCodes to help with reading
    ImageVoodoo.with_image(fn) do |img|
        img.with_crop(85, 1755, 600, 2300) do |imgt1|
            imgt1.rotate(270).save temp_qrcode1_filename
        end
    end
	class_and_name = ZXing.decode temp_qrcode1_filename
	if !class_and_name.nil?
		ImageVoodoo.with_image(fn) do |img|
			img.with_crop(85, 85, 600, 640) do |imgt2|
				imgt2.rotate(270).save temp_qrcode2_filename
			end
		end
		class_and_name = ZXing.decode temp_qrcode2_filename
		puts "Used second QR code."
	end
	if !class_and_name.nil?
		splat = class_and_name.split(':')
		if splat.length == 2
			@class_group = class_and_name.split(':')[0]
			@child_name = class_and_name.split(':')[1]
			return true
		else
			puts "Could not split qr code result into class and name on colon"
			return false
		end
	else
		puts "Could not extract anything from qr codes, moving to failed_scans."
		if !Dir.exist?(failed_scans_folder)
				Dir.mkdir(failed_scans_folder)
			end
			FileUtils.mv(fn, "#{failed_scans_folder}/#{base}")
		return false
	end
end

def processfile(fn)
	base = Pathname.new(fn).basename
	if !@classgroup.nil? || !@child_name.nil?
		# cut out artwork and save in cutouts/
		ImageVoodoo.with_image(fn) do |img|
			# Originally set to: 1170, 300, 3040, 2170
			#  moved along x by 30 and y by 20 to avoid box
			img.with_crop(1200, 320, 3040, 2170) do |img2|
				@artfile = "cutouts/#{@class_group} #{@child_name}.png"
				img2.rotate(270).save @artfile
			end
		end
		# make card and save in cards/class_group/child(originalscan)
		if !Dir.exist?("#{@dest}/#{@class_group}")
			puts "Making subfolder in #{@dest} for class #{@class_group}"
			Dir.mkdir("#{@dest}/#{@class_group}")
		end
		pdf = Card.new(@artfile, @child_name, @class_group)
		pdf.render_file "#{@dest}/#{@class_group}/#{@child_name}(#{base}).pdf"
		puts "Created card: #{@class_group}/#{@child_name}(#{base}).pdf"
	else
		puts "Class or child name not identified"
	end
end

sourcepath = Pathname.new(@source)
if sourcepath.directory?
	puts "Looking for scanned images in #{@source}"
	Dir["#{sourcepath}/*.jpg"].each do |fn|
		if readQRcodes(fn)
			processfile fn
		end
	end
else
	puts "Processing single file #{@source}"
	processfile @source
end
