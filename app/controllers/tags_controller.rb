class TagsController < ApplicationController
  include ERB::Util

  def list
    @tags = Tag
      .where(user: current_user)
      .order(name: :asc)
      .paginate(page: params[:page], per_page: 10)
  end

  def suggestions
    prefix = params[:prefix]

    suggested_names = prefix.blank? ?
      [] : Tag.names_matching_prefix(prefix, current_user)

    respond_to do |format|
      format.html { head :bad_request }
      format.xml { render xml: suggested_names }
      format.json { render json: suggested_names.map { |name| html_escape(name) } }
    end
  end

  def delete
    tag = Tag.find(params[:id])
    if tag.destroy
      redirect_to :back, notice: "tag '#{tag.name}' is deleted"
    else
      redirect_to :back, alert: "fail to delete tag '#{tag.name}'"
    end
  end

  def edit
    tag = Tag.find(params[:id])

    if tag.update(tag_params)
      respond_to do |format|
        format.json { render json: { message: "tag '#{tag.name}' is updated"} }
      end
    else
      respond_to do |format|
        format.json do
          render status: :bad_request, json: {
            message: tag.errors.full_messages.join(' | ')
          }
        end
      end
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description)
  end
end