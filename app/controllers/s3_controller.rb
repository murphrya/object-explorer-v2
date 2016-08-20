class S3Controller < ApplicationController

  #root page of the s3 api logic. Used to interact with a S3 endpoint
  def index
    begin
      checkS3Connection
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @buckets_array = getBucketsList if session[:s3connection] == "Established"
    rescue Exception => error
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

  #Perform a test to see if the server is able to connect to the S3 object store
  def testS3Connection
    begin
      s3 = createS3Connection
      test_query = s3.buckets.collect(&:name)
      session[:s3connection] = "Established"

      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = getBucketsList if session[:s3connection] == "Established"
      flash.now[:success] = "Success: Test S3 Connection Complete"
    rescue Exception => error
      session[:s3connection] = "Disconnected (Error)"
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

  #Perform a test to see if the server is able to connect to the S3 object store
  def checkS3Connection
    begin
      s3 = createS3Connection
      test_query = s3.buckets.collect(&:name)
      session[:s3connection] = "Established"
    rescue Exception => error
      session[:s3connection] = "Disconnected (Error)"
    end
  end

  #Creates and returns the connection object to the S3 datastore
  def createS3Connection
    begin
      s3 = AWS::S3.new(:access_key_id => session[:s3username],
                       :secret_access_key => session[:s3password],
                       :s3_endpoint => session[:s3address],
                       :use_ssl => true
                      )
      return s3
    rescue Exception => error
      return nil
      flash.now[:danger] =  "Error Creating Connection: #{error}."
    end
  end

  #Returns an empty buckets array that contains a hash with empty keys
  def createEmptyBucketsArray
    begin
      return [{:name => '', :objects => '', :size => ''}]
    rescue Exception => error
      return [{:name => '', :objects => '', :size => ''}]
      flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
    end


  end

  #
  def getBucketsList
    begin
      s3 = createS3Connection
      list = s3.buckets.collect(&:name)
      buckets_array = []
      list.each do |bucket_name|
        buckets_array.push({:name => bucket_name, :objects => 'TBD', :size => 'TBD'})
      end
      return buckets_array
    rescue Exception => error
      return createEmptyBucketsArray
      flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
    end
  end
end
