# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# # Install dependencies
# RUN apt-get update && apt-get install -y \
#     exiftool \
#     libtag1-dev \
#     && rm -rf /var/lib/apt/lists/*

# Install taglib-ruby (version < 2)
# RUN gem install taglib-ruby --version '< 2' --no-document

# # Install ExifTool
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends \
#         exiftool \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# # Verify ExifTool installation
# RUN exiftool -ver

# Install dependencies
# RUN apt-get update && apt-get install -y \
#     exiftool \
#     cmake \
#     g++ \
#     make \
#     wget \
#     && rm -rf /var/lib/apt/lists/*

# # Build and install TagLib from source
# RUN cd /tmp && \
#     wget https://taglib.org/releases/taglib-1.13.1.tar.gz && \
#     tar -xzf taglib-1.13.tar.gz && \
#     cd taglib-1.13.1 && \
#     cmake . && make && make install && \
#     ldconfig && \
#     rm -rf /tmp/taglib-1.13*