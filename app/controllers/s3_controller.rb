class S3Controller < ApplicationController

  #root page of the s3 api logic. Used to interact with a S3 endpoint
  def index
    begin
      #checks if a query can be sent to the S3 endpoint.
      #Sets the s3connection variable to Established or Error
      checkS3Connection

      #Get the list of buckets if a connection can be Established
      #Return an empty list of buckets if a connection cant be established
      @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
      @buckets_array = getBucketsList if session[:s3connection] == "Established"

      #Get the list of objects for the selected bucket.
      #Returns an empty list of objects if the selected bucket value is None
      @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
      @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    rescue Exception => error
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
                       :use_ssl => session[:use_ssl]
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

      #for each S3 bucket collect statistics
      list.each do |bucket_name|
        obj_count = 0
        total_size = 0
        bucket = s3.buckets[bucket_name]

        #for each object in the bucket
        bucket.objects.each do |obj|
          obj_count +=1
          total_size += obj.content_length
        end

        #convert total_size from bytes to MB
        total_size = (total_size / 1024.0).round(2)
        #build the array of buckets
        buckets_array.push({:name => bucket_name, :objects => obj_count, :size => total_size})
      end
      return buckets_array
    rescue Exception => error
      return createEmptyBucketsArray
      flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
    end
  end

 #renders page after user selects a bucket to view
 def viewBucketObjects
   begin
     session[:s3bucket] = params["selection"]["bucket"]

     #Get the list of buckets if a connection can be Established
     #Return an empty list of buckets if a connection cant be established
     @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
     @buckets_array = getBucketsList if session[:s3connection] == "Established"

     #Get the list of objects for the selected bucket.
     #Returns an empty list of objects if the selected bucket value is None
     @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
     @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
     flash.now[:success] = "Success: Object list downloaded from the object endpoint."
   rescue Exception => error
     @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
     @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
     flash.now[:danger] =  "Error Loading Application: #{error}."
   end
 end

 #Helper method
 #returns an array of objects
 def getObjectsList
   begin
     #get a handle on the user selected bucket
     s3 = createS3Connection
     bucket = s3.buckets[session[:s3bucket]]

     #pull down a list of the object names only
     objects_array = []
    # final_objects_array = []

     #bucket.objects.each do |obj|
      # objects_array.push(obj.key)
     #end

     bucket.objects.each do |obj|
       objects_array.push({:name => obj.key, :size => (obj.content_length / 1024.0).round(2), :type => obj.content_type, :last_mod => obj.last_modified})
     end

     objects_array = createEmptyObjectsArray if objects_array.empty?

     return objects_array
     #if !objects_array.empty?
      # objects_array.each do |obj_name|
      #   final_objects_array.push({:name => obj_name, :size => '', :type => ''})
    #   end
    # else
    #    final_objects_array = [{:name => '', :size => '', :type => ''}]
    # end
    # return final_objects_array
   rescue Exception => error
    # return createEmptyObjectsArray
    return createEmptyObjectsArray
     flash.now[:danger] =  "Error Creating S3 Buckets List: #{error}."
   end
 end


def deleteBucket
  begin
    #get a handle on the user selected bucket
    target_bucket = params["selection"]["bucket"]
    s3 = createS3Connection
    bucket = s3.buckets[target_bucket]

    #if the bucket is empty delete it
    if bucket.empty?
        session[:s3bucket] = "No Bucket Selected" if session[:s3bucket] == target_bucket
        bucket.delete
        flash.now[:success] = "Success: Bucket " + target_bucket + " was deleted."
    else
        flash.now[:danger] =  "Error deleting bucket " + target_bucket + ": Bucket not empty."
    end

    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"

  rescue Exception => error
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    flash.now[:danger] =  "Error deleting bucket " + target_bucket + ": #{error}."
  end
end


def forceDeleteBucket
  begin
    #get a handle on the user selected bucket
    target_bucket = params["selection"]["bucket"]
    s3 = createS3Connection
    bucket = s3.buckets[target_bucket]

    #reset the selected bucket if its being deleted
    session[:s3bucket] = "No Bucket Selected" if session[:s3bucket] == target_bucket

    #delete all objects in the bucket
    bucket.objects.each do |obj|
      obj.delete
    end

    #delete the bucket
    bucket.delete

    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    flash.now[:success] = "Success: Bucket " + target_bucket + " was deleted."
  rescue Exception => error
    @currentS3connection = session[:s3connection]
    @currentS3address = session[:s3address]
    @currentS3username = session[:s3username]
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    flash.now[:danger] =  "Error deleting bucket " + target_bucket + ": #{error}."
  end
end


def createS3Bucket
  begin
    #generate a random bucket name
    name = params[:selection][:bucket]

    #connect to object endpoint
    s3 = createS3Connection

    #create the new bucket
    s3.buckets.create(name)

    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    flash.now[:success] = "Success: Bucket " + name + " was created"
  rescue Exception => error
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    flash.now[:danger] =  "Error deleting bucket " + target_bucket + ": #{error}."
  end
end


def createRandomS3Bucket
  begin
    #generate a random bucket name
    name = "s3-bucket-" + SecureRandom.hex(4)

    #connect to object endpoint
    s3 = createS3Connection

    #create the new bucket
    s3.buckets.create(name)

    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    flash.now[:success] = "Success: Bucket " + name + " was created"
  rescue Exception => error
    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    flash.now[:danger] =  "Error deleting bucket " + target_bucket + ": #{error}."
  end
end


def downloadS3Object
  begin
  #get the object name from user
  name = params[:object][:name]

  #connect to object endpoint
  s3 = createS3Connection

  bucket = s3.buckets[session[:s3bucket]]
  object = bucket.objects[name]

  #write file to disk
  File.open(object.key, 'wb') do |file|
    object.read do |chunk|
      file.write(chunk)
    end
  end

  #sendS3Object(object.key,object.content_type)
  send_file(object.key, :filename => object.key, :type => object.content_type, :disposition => "attachment")
  File.delete(object.key)

  rescue Exception => error
    flash.now[:danger] =  "Error: #{error}."
  end
end


def deleteS3Object
  begin
    #get the object name from user
    name = params[:object][:name]

    #connect to object endpoint
    s3 = createS3Connection

    bucket = s3.buckets[session[:s3bucket]]
    object = bucket.objects[name]
    object.delete

    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"

    flash.now[:success] = "Success: Object " + name + " was deleted."
  rescue Exception => error
    #Get the list of buckets if a connection can be Established
    #Return an empty list of buckets if a connection cant be established
    @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
    @buckets_array = getBucketsList if session[:s3connection] == "Established"

    #Get the list of objects for the selected bucket.
    #Returns an empty list of objects if the selected bucket value is None
    @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
    @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
    flash.now[:danger] =  "Error deleting object " + name + ": #{error}."
  end
end

def uploadS3Object
  begin
  #get the object name from user
  selected_file = params[:upload][:object]
  content_type = selected_file.content_type
  object_name = selected_file.original_filename.gsub(' ','_')

  #connect to object endpoint
  s3 = createS3Connection
  bucket = s3.buckets[session[:s3bucket]]
  obj = bucket.objects[object_name].write(open(selected_file.path))
  puts "Success!"


  #Get the list of buckets if a connection can be Established
  #Return an empty list of buckets if a connection cant be established
  @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
  @buckets_array = getBucketsList if session[:s3connection] == "Established"

  #Get the list of objects for the selected bucket.
  #Returns an empty list of objects if the selected bucket value is None
  @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
  @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
  redirect_to s3_index_path
  flash.now[:success] = "Success: "
  rescue Exception => error
  #Get the list of buckets if a connection can be Established
  #Return an empty list of buckets if a connection cant be established
  @buckets_array = createEmptyBucketsArray if session[:s3connection] != "Established"
  @buckets_array = getBucketsList if session[:s3connection] == "Established"

  #Get the list of objects for the selected bucket.
  #Returns an empty list of objects if the selected bucket value is None
  @objects_array = createEmptyObjectsArray if session[:s3bucket] == "No Bucket Selected"
  @objects_array = getObjectsList if session[:s3bucket] != "No Bucket Selected"
  flash.now[:danger] =  "Error #{error}."
  end
end




end
