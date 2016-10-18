require 'prawn'
require "prawn/measurement_extensions"

class Card < Prawn::Document

	def initialize
		@page_width = 30.cm
		@page_height = 16.cm

		super(page_size: [@page_width, @page_height], margin: 0)
		draw_targets
		draw_cuts
		draw_art
		draw_logo
		write_name
	end

	def draw_target_at(x, y)
		horizontal_line x-7, x+7, at: y
		vertical_line y+7, y-7, at: x
		stroke_circle [x, y], 5
		fill_circle [x, y], 2.5
	end

	def draw_cuts
		len = 0.5.cm
		of1 = 0.8.cm
		of2 = 1.1.cm
		horizontal_line 0, len, at: @page_height - of1
		horizontal_line 0, len, at: @page_height - of2
		horizontal_line 0, len, at: of1
		horizontal_line 0, len, at: of2
		horizontal_line @page_width, @page_width - len, at: @page_height - of1
		horizontal_line @page_width, @page_width - len, at: @page_height - of2
		horizontal_line @page_width, @page_width - len, at: of1
		horizontal_line @page_width, @page_width - len, at: of2

		vertical_line 0, len, at: of1
		vertical_line 0, len, at: of2
		vertical_line 0, len, at: @page_width - of1
		vertical_line 0, len, at: @page_width - of2
		vertical_line @page_height, @page_height - len, at: of1
		vertical_line @page_height, @page_height - len, at: of2
		vertical_line @page_height, @page_height - len, at: @page_width - of1
		vertical_line @page_height, @page_height - len, at: @page_width - of2
	end

	def draw_targets
		pt = 7
		self.line_width = 0.1
		draw_target_at pt, 8.cm
		draw_target_at 15.cm, pt
		draw_target_at 15.cm, 16.cm - pt
		draw_target_at 30.cm - pt, 8.cm
	end

	def draw_art
		image "voocard.jpg", at: [15.cm, 15.cm], width: 14.cm
		self.line_width = 0.1
		stroke_rectangle [15.cm, 15.cm], 14.cm, 14.cm
		text_box "Artwork is approx: 14cm or #{14.cm.pt.round} pixels square.", at: [16.cm, 14.cm]
	end

	def draw_logo
		image "logo-large.png", width: 2.cm, at: [7.cm, 5.cm]
	end

	def write_name
		child_name = "Anne X Ample"
		child_age = 5
		text_box "Drawing by #{child_name}\nAge #{child_age}", at: [1.cm, 2.5.cm], align: :center, width: 14.cm, height: 1.cm
	end
end

# draw cut lines
# draw school logo
# draw artwork

pdf = Card.new
pdf.render_file "card.pdf"