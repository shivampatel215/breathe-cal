class MarkersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if session[:client_id] != nil 
      marker = Marker.create!(marker_params.merge(:client_id => session[:client_id]))
      render :json => marker
    else 
      render :nothing => true
    end 
  end

  def delete 
    Marker.delete_marker(params[:id])
    render :json => Marker.all
  end

  def edit
    Marker.edit_marker(params[:id], params[:title])
    render :json => Marker.all
  end
  
  def show
    global_number_show = 2
    current_user_id = session[:client_id]
    coords = {top: bound_params[:uplat], bottom: bound_params[:downlat], 
              left: bound_params[:leftlong], right: bound_params[:rightlong]}
    
    all_markers = Marker.find_all_in_bounds(coords,'','')
    user_markers = all_markers.select { |m| m.client_id == current_user_id }
    global_markers = []
    
    # gets all possible markers in bounds
    @marker_types_in_bounds = user_markers.uniq { |m| m.title }
    @marker_types_in_bounds = @marker_types_in_bounds.map { |m| m.title }
    
#     # do the filtering
    # if params[:filter] && (params[:filter].keys.length > 0)
      filtered_allergen = ''
      # filtered_allergen = Marker.sanitize(params[:filter])
      # all_markers = all_markers.select { |m| filtered_allergen == m.title }
      global_markers = Marker.get_global_markers(all_markers,global_number_show,coords,filtered_allergen)
   # end
    
    # pass collection to gmaps.js
    marker_container = [user_markers, global_markers, @marker_types_in_bounds]
    
    
    # respond_to do |format|
    #   format.html
    #   format.js
    #   format.json { render :json => marker_container }
    # end
    
    render :json => marker_container
  end
  
  
  private 
  
  def marker_params
    params.require(:marker).permit(:lat, :lng, :cat, :dog, :mold, :bees, :perfume, :oak, :peanut, :gluten, :dust, :smoke, :title)
  end
  
  def bound_params
    params.require(:bounds).permit(:uplat,:downlat,:rightlong,:leftlong)
  end
  
end
