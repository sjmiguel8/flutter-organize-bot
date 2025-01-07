FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"
RUN flutter doctor
RUN flutter config --enable-web

# Copy the app
COPY . /app/
WORKDIR /app/

# Build
RUN flutter build web

# Serve the app
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html 