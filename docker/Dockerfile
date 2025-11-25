FROM continuumio/miniconda:4.6.14

WORKDIR /app

RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false -o APT::Get::AllowUnauthenticated=true

# Install build tools needed for compiling samtools from source
RUN apt-get install -y --allow-unauthenticated \
    build-essential \
    wget \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install samtools 1.3.1 manually from source
RUN cd /tmp && \
    wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar -xjf samtools-1.3.1.tar.bz2 && \
    cd samtools-1.3.1 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd / && rm -rf /tmp/samtools-1.3.1*


# Copy TEProf2.yml to container
COPY TEProf2.yml /app/TEProf2.yml

# Clone TEProf2Paper repository
RUN git clone https://github.com/junseokpark/TEProf2Paper.git /app/TEProf2Paper

WORKDIR /app/TEProf2Paper

# Create environment from TEProf2.yml file (Python 2.7 with all dependencies)
RUN conda env create -f /app/TEProf2.yml

# Activate environment for subsequent commands
SHELL ["conda", "run", "-n", "teprof2", "/bin/bash", "-c"]

RUN R --no-save --no-restore <<'EOF'
options(download.file.method = "wget")
options(timeout = 600)
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("========================================\n")
cat("Installing R Packages\n")
cat("Using manual installation script\n")
cat("========================================\n\n")

# Step 1: Base dependencies
cat("=== Step 1: Installing base dependencies ===\n")

install.packages("BiocManager")

# BiocInstaller is deprecated; use BiocManager instead
install.packages("BiocInstaller", repos="https://bioconductor.org/packages/3.1/bioc")

# Install archived Xmisc package
install.packages("https://cran.r-project.org/src/contrib/Archive/Xmisc/Xmisc_0.2.1.tar.gz",repos = NULL,type = "source")
cat("\nBuild completed.\n")
EOF

# Verify cPickle is available in Python 2.7

RUN python - << 'EOF'
import cPickle
print("cPickle module available")
EOF

# Add bin folder to PATH
ENV PATH="/app/TEProf2Paper/bin:$PATH"

# Make sure the bin directory exists and is executable
RUN mkdir -p /app/TEProf2Paper/bin && chmod -R +x /app/TEProf2Paper/bin/ 2>/dev/null || true

# Set the default shell to use the teprof2 environment
RUN echo "source activate teprof2" >> /etc/bash.bashrc

ENTRYPOINT ["/bin/bash"]
CMD ["-i"]