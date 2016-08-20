class S3Controller < ApplicationController

  #root page of the s3 api logic. Used to interact with a S3 endpoint
  def index
    begin
      #checks if a query can be sent to the S3 endpoint.
      #Sets the s3connection variable to Established or Error
      checkS3Connection
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]

      #Get the list of buckets if a connection can be Established
      #Return an empty list of buckets if a connection cant be established
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @buckets_array = getBucketsList if session[:s3connection] == "Established"

      #Get the list of objects for the selected bucket.
      #Returns an empty list of objects if the selected bucket value is None
      @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
      @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    rescue Exception => error
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

  #Perform a test to see if the server is able to connect to the S3 object store
  def testS3Connection
    begin
      #checks if a query can be sent to the S3 endpoint.
      #Sets the s3connection variable to Established or Error
      s3 = createS3Connection
      test_query = s3.buckets.collect(&:name)
      session[:s3connection] = "Established"
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]

      #Get the list of buckets if a connection can be Established
      #Return an empty list of buckets if a connection cant be established
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @buckets_array = getBucketsList if session[:s3connection] == "Established"

      #Get the list of objects for the selected bucket.
      #Returns an empty list of objects if the selected bucket value is None
      @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
      @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
      flash.now[:success] = "Success: Enpoint connection refreshed."
    rescue Exception => error
      session[:s3connection] = "Disconnected (Error)"
      @currentS3connection = session[:s3connection]
      @currentS3address = session[:s3address]
      @currentS3username = session[:s3username]
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
      flash.now[:danger] =  "Error Loading Application: #{error}."
    end
  end

  #Helper method
  #Perform a test to see if the server is able to connect to the S3 object store
  def checkS3Connection
    begin
      s3 = createS3Connection
      test_query = s3.buckets.collect(&:name)
      session[:s3connection] = "Established"
    rescue Exception => error
      session[:s3connection] = "Disconnected (Error)"
      flash.now[:danger] =  "Error Connecting to S3 Endpoint: #{error}."
    end
  end

  #Helper method
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

  #Helper method
  #Returns an empty buckets array that contains a hash with empty keys
  def createEmptyBucketsArray
    begin
      return [{:name => '', :objects => '', :size => ''}]
    rescue Exception => error
      return [{:name => '', :objects => '', :size => ''}]
      flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
    end
  end

  #Helper method
  #Returns an empty objects array that contains a hash with empty keys
  def createEmptyObjectsArray
    begin
      return [{:name => '', :size => '', :type => ''}]
    rescue Exception => error
      return [{:name => '', :size => '', :type => ''}]
      flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
    end
  end

  #Helper method
  #Returns an array of bucket hashes
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


 def viewBucketObjects
   begin
     session[:s3bucket] = params["selection"]["bucket"]
     puts session[:s3bucket].to_s
     @currentS3connection = session[:s3connection]
     @currentS3address = session[:s3address]
     @currentS3username = session[:s3username]

     #Get the list of buckets if a connection can be Established
     #Return an empty list of buckets if a connection cant be established
     @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
     @buckets_array = getBucketsList if session[:s3connection] == "Established"

     #Get the list of objects for the selected bucket.
     #Returns an empty list of objects if the selected bucket value is None
     @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
     @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
   rescue Exception => error
     @currentS3connection = session[:s3connection]
     @currentS3address = session[:s3address]
     @currentS3username = session[:s3username]
     @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
     @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
     flash.now[:danger] =  "Error Loading Application: #{error}."
   end
 end


 def getObjectsList
   begin
     s3 = createS3Connection
     bucket = s3.buckets[session[:s3bucket]]

     objects_array = []
     final_objects_array = []
     bucket.objects.each do |obj|
       objects_array.push(objects_array.push(obj.key))
     end

     if !objects_array.empty?
       objects_array.each do |obj_name|
         final_objects_array.push({:name => obj_name, :size => '', :type => ''})
       end
     else
        final_objects_array = [{:name => '', :size => '', :type => ''}]
     end
     return final_objects_array
   rescue Exception => error
     return createEmptyObjectsArray
     flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
   end
 end







end
