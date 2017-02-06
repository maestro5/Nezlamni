class CommentsController < ApplicationController
  before_action :set_account
  before_action :set_comment, only: %i(edit update destroy)

  def create
    @comment = @account.comments.create(comment_params)
  end

  def update
    @comment.update(comment_params)
  end

  def destroy
    @comment.destroy
  end

private
  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body).merge(user_id: current_user.id)
  end
end
