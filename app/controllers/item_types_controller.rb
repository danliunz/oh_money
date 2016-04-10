class ItemTypesController < ApplicationController
  def edit_form
    @item_type = ItemType.find(params[:id])
  end

  def edit
    @item_type = ItemType.find(params[:id])

    update_item_type = UpdateItemType.new(@item_type, item_type_params)
    if update_item_type.call
      flash.notice = "product #{@item_type.name} is updated"
      redirect_to edit_item_type_form_url(@item_type)
    else
      flash.now.alert = update_item_type.error
      render "edit_form"
    end
  end

  def suggestions
    prefix = params[:prefix]

    suggested_names = prefix.blank? ?
      [] : ItemType.names_matching_prefix(prefix, current_user)

    respond_to do |format|
      format.html { head :bad_request }
      format.xml { render xml: suggested_names }
      format.json { render json: suggested_names }
    end
  end

  private

  def item_type_params
    params
      .require(:item_type)
      .permit(:description, parents: [])
  end
end