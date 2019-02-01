class ApplicationController < ActionController::API
  def force_exception
    raise "Forced exception."
  end
end
