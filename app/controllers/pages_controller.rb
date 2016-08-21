class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @accounts = Account.all
  end
end
