class CommentsController < ApplicationController
  before_action :find_entry
  before_action :find_comment, except: %i(new create)
  before_action :comment_owner, only: %i(destroy update edit)

  def create
    @comment = @entry.comments.create comment_params
    @comment.user_id = current_user.id
    @comment.save
    @comments = Comment.where(entry_id: @entry)
    if @comment.save
      respond_to {|format| format.js}
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    if @comment.update comment_params
      respond_to {|format| format.js}
    end
  end

  def destroy
    if @comment.destroy
      flash[:success] = "delete success"
    else
      flash[:danger] =  "delete error"
    end
    redirect_to entry_path @entry
  end

  private

  def comment_params
    params.require(:comment).permit :content
  end

  def find_entry
    @entry = Entry.find params[:entry_id]
    return unless @entry.nil?
    flash[:danger] = "entry not found"
    redirect_to entry_path @entry
  end

  def find_comment
    @comment = @entry.comments.find params[:id]
    return unless @comment.nil?
    flash[:danger] = "comment not found"
    redirect_to entry_path @entry
  end

  def comment_owner
    return if current_user.id == @comment.user.id
    flash[:warning] = "not pass"
    redirect_to @entry
  end

  def authenticate_user
    return if current_user.present?
    flash[:danger] = "sign up not found"
    redirect_to login_url
  end
end
