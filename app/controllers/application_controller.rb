class ApplicationController < ActionController::Base
  def error_response(code, message, data = {})
  	render :json => {success: false, message: message, data: data}, :status => code
  end
  def success_response(message, data = {})
  	render :json => {success: true, message: message, data: data}
  end
end
