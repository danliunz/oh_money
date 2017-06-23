class ItemTypesController < ApplicationController
  include ERB::Util

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
    children.sort_by { |a| a.name }.each do |child|
      response << { data: child.id, text: html_escape(child.name), children: !child.children.empty? }
    end

    render json: response
  end

  def delete
    item_type = ItemType.find(params[:id])

    if item_type.destroy
      redirect_to list_item_types_url, notice: "#{item_type.name} is deleted"
    else
      redirect_to list_item_types_url, alert: "fail to delete #{item_type.name}"
    end
  end

  def show
    @item_type = ItemType.find(params[:id])

    remember_return_url(request.env["HTTP_REFERER"] || list_item_types_url)
  end

  def edit
    @item_type = ItemType.find(params[:id])
    update_item_type = UpdateItemType.new(@item_type, item_type_params)

    if update_item_type.call
      redirect_to take_return_url, notice: "#{@item_type.name} is updated"
    else
      flash.now.alert = "update failure: " + update_item_type.error
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
      format.json { render json: suggested_names.map { |name| html_escape(name) } }
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

  def remember_return_url(url)
    session[:item_types_return_url] = url
  end

  def take_return_url
    url = session[:item_types_return_url]
    session[:item_types_return_url] = nil

    url
  end
end