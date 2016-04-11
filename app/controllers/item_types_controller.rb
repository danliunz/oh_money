class ItemTypesController < ApplicationController
  before_action :require_authorized_user, only: [:get_children, :delete, :show, :edit]

  def list
  end

  def get_children
    item_type_id = params[:id]

    if wildcard_id?(item_type_id)
      children = ItemType.roots(current_user)
    else
      children = ItemType.find(item_type_id).children
    end

    response = []
    children.each do |child|
      response << { id: child.id, text: child.name, children: !child.children.empty? }
    end

    render json: response
  end

  def delete
    item_type = ItemType.find(params[:id])
    item_type.destroy

    flash.notice = "#{item_type.name} is deleted"
    redirect_to list_item_types_url
  end

  def show
    @item_type = ItemType.find(params[:id])
  end

  def edit
    @item_type = ItemType.find(params[:id])

    update_item_type = UpdateItemType.new(@item_type, item_type_params)
    if update_item_type.call
      flash.notice = "#{@item_type.name} is updated"
      redirect_to list_item_types_url
    else
      flash.now.alert = update_item_type.error
      render "show"
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

  # JSTree convention: pass '#' as id when loading root nodes
  def wildcard_id?(item_type_id)
    item_type_id == "#"
  end

  def require_authorized_user
    item_type_id = params[:id]

    if item_type_id && !wildcard_id?(item_type_id)
      item_type = ItemType.find(item_type_id)

      if item_type.user != current_user
        redirect_to signin_url, alert: "Authorization failure. Try signin as another user"
      end
    end
  end

  def item_type_params
    params
      .require(:item_type)
      .permit(:name, :description, parents: [])
  end
end