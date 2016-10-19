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
        create_header
        create_drawing_box
        create_footer
    end
    
    def create_header()
        text "Christmas card template"
        text @name
        qrcode = RQRCode::QRCode.new("#{@class_group}:#{@name}")
        png = qrcode.as_png(size: 120)
        IO.write("temp_code.png", png.to_s)
        image "temp_code.png", at: [400, 120]
    end
    
    def create_drawing_box()
        stroke_axis
        line_width = 0.1
		stroke_rectangle [0, 25.cm], 19.cm, 19.cm
    end
    
    def create_footer()
        move_cursor_to 160
        text "Help and howtos."
    end
end

logins = Array.new

# open the text file
fn = ARGV[0]
f = File.open("#{fn}", "r")

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

logins.each do |login|
    pdf = Template.new(login.name, login.class_group)
    pdf.render_file "./templates/#{login.login}.pdf"
end