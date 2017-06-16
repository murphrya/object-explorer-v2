## Overview
Object Explorer is a Ruby on Rails web application that can connect to and interact with S3 compatible object storage. Operations include creating/deleting buckets and uploading, downloading, and deleting objects. The application is currently a beta release, running in Rails development mode. I would recommend running this application or container on host that has 2-3GB of RAM available.

![img1](https://raw.githubusercontent.com/murphrya/object-explorer-v2/master/github_img1.PNG)
![img1](https://raw.githubusercontent.com/murphrya/object-explorer-v2/master/github_img2.PNG)


## Run Locally

1. Install Ruby version 2.2.5 or 2.3.1.

2. Perform a git clone of the repository: ```git clone https://github.com/murphrya/object-explorer-v2.git```

3. Change into the Object Explorer directory: ```cd object-explorer-v2/```

4. Perform a bundle install: ```bundle install```

5. Start the Rails server: ```rails s ```

6. Load the application in Chrome or Firefox: ```http://your-address:3000```


## Docker Container
For Docker/AWS users I have a container available. The container can be downloaded from my docker hub account.

1. Pull down and run the container: ```docker run -d -p 3000:3000 murphrya/object-explorer-v2```

2. Get container ID: ```docker ps -l```

3. Find containers IP address: ```docker inspect CONTAINER-ID | grep IPAddress```

4. Connect to Object Explorer: ```http://CONTAINER-IP:3000``` or ```http://DOCKER-HOST-IP:3000```


## Pivotal Web Services/Pivoal Cloud Foundry
Object Explorer is also PWS/CF ready and comes with a manifest file.

1. Edit the manifest.yml file to set how many instances you want to launch: ```  instances: xx```

2. Log into the CF cli: ```cf login -a api.run.pivotal.io```

3. Ensure the application assests are compiled: ```rake assets:precompile```

4. Push the application to PWS/CF: ```cf push object-explorer-v2```

## Licensing
Copyright (c) 2016 Ryan Murphy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
