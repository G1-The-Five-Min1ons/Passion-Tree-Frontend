# Multi-stage build for Flutter Web frontend served by Nginx

## Build stage: fetch Flutter SDK and compile web assets
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   ca-certificates \
	   curl \
	   git \
	   unzip \
	   xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# Install Flutter SDK (stable channel)
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME" \
	&& flutter config --no-analytics --enable-web \
	&& flutter precache --web

WORKDIR /app

# Cache pub dependencies first
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the rest of the source and build for web
COPY . .
RUN flutter build web --release --no-tree-shake-icons

## Runtime stage: serve built assets via Nginx
FROM nginx:1.25-alpine AS runner

# Replace default site with SPA-friendly config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled web assets
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

