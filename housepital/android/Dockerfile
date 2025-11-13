# Step 1: Base image
FROM ubuntu:22.04

# Step 2: Install basic dependencies (with Java)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    wget \
    ca-certificates \
    libglu1-mesa \
    openjdk-17-jdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Step 3: Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_ROOT=/opt/flutter
ENV PUB_CACHE=/opt/flutter/.pub-cache
ENV PATH="$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"
ENV CI=true
ENV USER=root
ENV FLUTTER_SUPPRESS_ANALYTICS=true
ENV FLUTTER_ALLOW_ROOT=true

# Step 4: Set working directory
WORKDIR /app

# Step 5: Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /opt/flutter -b stable && \
    flutter config --no-analytics && flutter precache

# Step 6: Install Android SDK Command-line tools
RUN mkdir -p /opt/android-sdk/cmdline-tools && cd /opt/android-sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && \
    mkdir -p /opt/android-sdk/cmdline-tools/latest && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools/* /opt/android-sdk/cmdline-tools/latest/ || true

# Step 7: Accept licenses and install required Android packages
RUN bash -c "yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses" && \
    bash -c "/opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk --update" && \
    bash -c "/opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk \
        'platform-tools' \
        'platforms;android-34' \
        'build-tools;34.0.0'"

# Step 8: Copy entire Flutter project (context comes from project root)
COPY . /app

# Step 9: Move into the actual Flutter project folder
WORKDIR /app/housepital

# Step 10: Get dependencies and build
RUN flutter config --no-analytics && flutter pub get

# Step 11: Default command
CMD ["bash"]