class JobPdf < Prawn::Document
  def initialize(job, view)

    super({:page_size => [235, 110]})
    @job = job
    @view = view
    move_up 35

    bounding_box([0, cursor], :width => 233) do
      formatted_text [ 
        { :text => "Singapore"},
        { :text => "Swimming", :styles => [:bold] },
        { :text => "Academy"}
      ], :align => :left
    end

    bounding_box([-35, cursor], :width => 230, :height => 100) do
      move_down 6
      text "<font size='18'>#{@job.print_lead_name.titleize}</font>", :style => :bold, :inline_format => true
      [:top].each do |vposition|
        text "<font size='16'>#{@job.print_lead_address}", :valign => vposition, :vposition => vposition, :inline_format => true
      end
    end

    font_size(10) do
      draw_text "#{@job.print_quantity}pcs #{@job.id}", :at => [130, -32]
    end

  end
end
