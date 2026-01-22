ARG RUBY_VERSION=3.4.1
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# # Install additional system packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     imagemagick \
#     libvips \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Optionally install dependencies early
# WORKDIR /workspace
# COPY Gemfile Gemfile.lock ./
# RUN bundle install

# # Copy the rest of the app
# COPY . .
