class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound do
    respond_to do |type|
      type.all { render nothing: true, status: 404 }
    end
  end
end
