FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    autoconf \
    pkg-config \
    libssl-dev \
    git \
    g++ \
    cmake \
    ca-certificates \
    iproute2 \
    vim \
    netcat-traditional \
    reptyr \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /quickfix-project

# Clone QuickFIX separately for better error handling
RUN git clone https://github.com/quickfix/quickfix.git .

# Build QuickFIX
WORKDIR /quickfix-project
RUN ./bootstrap && ./configure && make && make install

# Ensure the system can find QuickFIX shared libraries
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/quickfix.conf && ldconfig

# Permanently set LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Ensure shared libraries & executables are found
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PATH="/usr/local/bin:$PATH"

# Build executor example (which includes initiator and acceptor)
WORKDIR /quickfix-project/examples/executor/C++
RUN make

# Build tradeclient example
WORKDIR /quickfix-project/examples/tradeclient
RUN make

# Copy executables to /usr/local/bin/
RUN cp /quickfix-project/examples/executor/C++/.libs/executor /usr/local/bin/executor && chmod +x /usr/local/bin/executor

# Copy the compiled tradeclient binary to /usr/local/bin/
RUN cp /quickfix-project/examples/tradeclient/.libs/tradeclient /usr/local/bin/tradeclient && chmod +x /usr/local/bin/tradeclient

# Copy configuration files *AFTER* QuickFIX is built
WORKDIR /quickfix-project
COPY acceptor.cfg initiator.cfg FIX44.xml ./config/

# Expose FIX port
EXPOSE 5001

# Default command (Keep container running)
CMD ["tail", "-f", "/dev/null"]
