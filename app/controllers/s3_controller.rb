class S3Controller < ApplicationController

  #root page of the s3 api logic. Used to interact with a S3 endpoint
  def index
    begin
      session[:s3connection] = 'Disconnected' if session[:s3connection] == nil

      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
    rescue Exception => error
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

end
