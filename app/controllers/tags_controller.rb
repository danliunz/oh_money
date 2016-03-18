class TagsController < ApplicationController
  def suggestions
    prefix = params[:prefix]

    suggested_names = prefix.blank? ?
      [] : Tag.names_matching_prefix(prefix, current_user)

    respond_to do |format|
      format.html { head :bad_request }
      format.xml { render xml: suggested_names }
      format.json { render json: suggested_names }
    end
  end
end