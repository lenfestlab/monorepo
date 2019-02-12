class ApplicationController < ActionController::API

  def force_compression
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def force_exception
    raise "Forced exception."
  end

end
