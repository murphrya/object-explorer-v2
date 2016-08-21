class MainController < ApplicationController

  #root page of the application. Used to set object storage credentials
  def index
    begin
      #if this is the first time the application has been loaded
      session[:s3address] = "Not Set" if session[:s3address] == nil
      session[:s3username] = "Not Set" if session[:s3username] == nil
      session[:s3password] = "Not Set" if session[:s3password] == nil
      session[:use_ssl] = "true" if session[:use_ssl] == nil
      session[:s3connection] = "Disconnected" if session[:s3connection] == nil
      session[:s3bucket] = "No Bucket Selected"
    rescue Exception => error
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

  #AJAX method used to store the users S3 object storage credentials
  def setS3
    begin
      #pull the s3 object storage credentials from the user form input
      session[:s3address] = params[:selection][:s3address]
      session[:s3username] = params[:selection][:s3username]
      session[:s3password] = params[:selection][:s3password]
      session[:use_ssl] = params[:selection][:use_ssl]
      session[:s3bucket] = "No Bucket Selected"
      flash.now[:success] = "Success: S3 Credentials have been set."
    rescue Exception => error
      session[:s3bucket] = "No Bucket Selected"
      flash.now[:danger] =  "Error Setting S3 Credentials: #{error}."
    end
  end

  #AJAX method used to wipe the users S3 object storage credentials
  def wipeS3Credentials
    begin
      #wipe the S3 credentials
      session[:s3address] = "Not Set (User Wiped)"
      session[:s3username] = "Not Set (User Wiped)"
      session[:s3password] = "Not Set (User Wiped)"
      session[:s3connection] = "Disconnected (User Wiped)"
      session[:s3bucket] = "No Bucket Selected"
      flash.now[:success] = "Success: S3 Credentials have wiped."
    rescue Exception => error
      session[:s3bucket] = "No Bucket Selected"
      flash.now[:danger] =  "Error Wiping S3 Credentials: #{error}."
    end
  end

  #displays the current running server configuration
  def softwareLevels
    begin
      @ruby_version = RUBY_VERSION
      @rails_version = Gem.latest_spec_for('rails').version.to_s
      @os_type = RUBY_PLATFORM
      @server_instance = Socket.gethostname
      @server_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
      @bootstrap_version = Gem.latest_spec_for('bootstrap-sass').version.to_s
      @aws_version = Gem.latest_spec_for('aws-sdk-v1').version.to_s
    rescue Exception => error
      flash.now[:danger] =  "Error pulling server configuration: #{error}."
    end
  end

end
