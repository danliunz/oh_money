class ItemTypesController < ApplicationController
  def suggestions
    hint = params[:hint]

    if hint.blank?
      item_type_names = []
    else
      item_type_names = ItemType
        .where(user: current_user)
        .where("name LIKE ?", "%#{hint}%")
        .pluck(:name)
    end

    respond_to do |format|
      format.html { head :bad_request }
      format.xml { render xml: item_type_names }
      format.json { render json: item_type_names }
    end
  end
end