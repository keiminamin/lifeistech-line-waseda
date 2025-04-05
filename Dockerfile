# Use the official Ruby image matching the version in Gemfile
FROM ruby:3.0.0

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies
# - build-essential: For compiling native extensions
# - libpq-dev: Required by the 'pg' gem to connect to PostgreSQL
# - nodejs: Often needed for asset pipelines, though not strictly required by this Gemfile alone. Good practice to include.
# Clean up APT cache to keep image size down
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
# Copying these first leverages Docker layer caching
COPY Gemfile Gemfile.lock ./

# Install Ruby gems using Bundler
# --jobs: Use multiple cores for faster installation
# --retry: Retry installation if network issues occur
# It's generally recommended to use --deployment in production,
# which requires Gemfile.lock to be present and up-to-date.
# We'll use standard install here for simplicity.
RUN bundle install --jobs=$(nproc) --retry=3

# Copy the rest of the application code into the container
COPY . .

# Expose the port Sinatra runs on (default is 4567)
EXPOSE 4567

# Environment variables - Set defaults or placeholders
# IMPORTANT: Provide actual sensitive values (DATABASE_URL, Cloudinary keys)
#            at runtime, NOT hardcoded here.
ENV RACK_ENV=production \
    PORT=4567 \
    DATABASE_URL="postgresql://user:password@db_host:5432/database_name" \
    CLOUDINARY_CLOUD_NAME="your_cloud_name" \
    CLOUDINARY_API_KEY="your_api_key" \
    CLOUDINARY_API_SECRET="your_api_secret"

# Command to run the application using rackup (which uses config.ru)
# -o 0.0.0.0: Binds to all interfaces inside the container
# -p $PORT: Uses the PORT environment variable
CMD ["bundle", "exec", "rackup", "config.ru", "-o", "0.0.0.0", "-p", "$PORT"]