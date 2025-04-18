FROM ruby:3.4.3
COPY Gemfile Gemfile.lock ./
RUN bundle install
ENTRYPOINT ["ruby", "main.rb"]
