require 'prawn'
require "prawn/measurement_extensions"
require 'zxing'
require 'rqrcode'

class Template < Prawn::Document
    def initialize()
        super(page_size: 'A4', margin: 1.cm)
        create_header
        create_drawing_box
        create_footer
    end
    
    def create_header()
        text "Christmas card template"
        text "Name of child"
        qrcode = RQRCode::QRCode.new("Y5 Wolds:00976:Anne X Ample")
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
        text "How many cards, etc."
    end
end

pdf = Template.new
pdf.render_file "template.pdf"