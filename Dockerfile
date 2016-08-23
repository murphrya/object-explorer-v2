# Base image
FROM ruby:2.2.3

ENV HOME /home/rails/webapp

# Install PGsql dependencies and js engine
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR $HOME

# Install gems
ADD Gemfile* $HOME/
RUN gem install bundle
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

# Add the app code
ADD . $HOME

# Default command
CMD ["rails", "server", "--binding", "0.0.0.0"]
