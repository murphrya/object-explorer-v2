Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #main application root route
  root 'main#index'

  #main page routes
  get 'main/index'
  get 'main/setS3'
  post 'main/setS3'
  get 'main/softwareLevels'
  get 'main/wipeS3Credentials'
  post 'main/wipeS3Credentials'
  get 'main/wipeSwiftCredentials'
  post 'main/wipeSwiftCredentials'

  #s3 page routes
  get 's3/index'
  get 's3/testS3Connection'
  post 's3/testS3Connection'
  get 's3/viewBucketObjects'
  post 's3/viewBucketObjects'
  get 's3/deleteBucket'
  post 's3/deleteBucket'
  get 's3/forceDeleteBucket'
  post 's3/forceDeleteBucket'
  get 's3/createS3Bucket'
  post 's3/createS3Bucket'
  get 's3/createRandomS3Bucket'
  post 's3/createRandomS3Bucket'


  #swift page routes
  get 'swift/index'







end
