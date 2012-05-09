class ScreenController < ApplicationController
  def blank
    render :action=>:blank, :layout=>false
  end

end
