require 'prawn'
require "prawn/measurement_extensions"
require 'zxing'
require 'rqrcode'

class Login <
	Struct.new(:name, :login, :password, :role, :shared_folders, :class_group, :upn)
end

class Template < Prawn::Document
    def initialize(name, class_group)
        @name = name
        @class_group = class_group
        super(page_size: 'A4', margin: 1.cm)
        register_fonts
        create_header
        create_drawing_box
        create_qrcode
        create_footer
    end
    
    def register_fonts
        # Registering all desired fonts (must be done per document)
        puts "Registering fonts"
        font_families.update("PWJoyeuxNoel" => {:normal => "./fonts/pwjoyeuxnoel/PWHappyChristmas.ttf"})
        font_families.update("Amaranth" => {:normal => "./fonts/Amaranth/Amaranth-Regular.ttf"})
    end

    
    def create_header()
        image "./fons-circular.png", width: 2.5.cm, at: [140.mm, 282.5.mm]
        image "./logo-large.png", width: 2.5.cm, at: [165.mm, 282.5.mm]
        font "PWJoyeuxNoel"
        font_size 43
        text "A Christmas Card"
        font "Amaranth"
        font_size 18
        text "By #{@name} (#{@class_group})", inline_format: true # need bold version of font for <b> inline formatting, I guess
    end
    
    def create_qrcode()
        qrcode = RQRCode::QRCode.new("#{@class_group}:#{@name}")
        png = qrcode.as_png(size: 120)
        IO.write("temp_code.png", png.to_s)
        image "temp_code.png", at: [400, 120]
    end
    
    def create_drawing_box()
        stroke_axis
        line_width = 0.1
		stroke_rectangle [1.5.cm, 25.cm], 16.cm, 16.cm
    end
    
    def create_footer()
        move_cursor_to 9.cm
        font "Amaranth"
        font_size 12
        text "#{@name.split(" ")[0]},"
        text "Draw and colour your design in the box above. You can colour right up to the edge of the box but don’t put important words or pictures too close as they might be cut off! Don’t draw or mark outside it."
        qrcode = RQRCode::QRCode.new("#{@class_group}:#{@name}")
        font "Helvetica"
        font_size 10
        move_down 10
        text "Parents/carers,"
        move_down 10
        text "Room for introduction and more information about the fundraiser."
        move_down 10
        text "Cards are about 15cm square and are printed and supplied in packs of 12. Your child's name and the school logo are printed on the back. The inside is left blank. This page will be scanned so please ensure that it stays flat and clean. Applique or collage designs are not suitable. Make sure the QRCode is not marked as it is the only way to identify your child's work."
        bounding_box([40, 40], width: 340) do
            text "Packs cost £5 each. Please put the number of packs you require in the box on the left and return this form, with payment, by Thursday 17th November."
            text "Thank you for your support!"
        end
        stroke_rectangle [0, 40], 30, 30
    end
end

logins = Array.new

# open the text file
fn = ARGV[0]
f = File.open("#{fn}", "r")

# Hide error triggered by £ sign in footer.
Prawn::Font::AFM.hide_m17n_warning = true

# loop through each record in the pupils.mash file from Rooster adding each record to our array.
f.each_line { |line|
	fields = line.split("\t")
	login = Login.new
	login.name = fields[0]
	login.login = fields[1]
	login.password = fields[2]
	login.role = fields[3]
	login.shared_folders = fields[4]
	login.class_group = fields[5]
	login.upn = fields[6]
    logins.push(login)
}

puts "Ready to create templates for pupils in file #{fn}"
logins.each do |login|
    puts "#{login.name}..."
    pdf = Template.new(login.name, login.class_group)
    pdf.render_file "./templates/#{login.login}.pdf"
    puts "done."
end