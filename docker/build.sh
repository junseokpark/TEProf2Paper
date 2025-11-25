#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Building TEProf2 Docker Image${NC}"
echo -e "${YELLOW}========================================${NC}"

# Build the Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build  \
    --platform linux/amd64 \
    -t teprof2:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}Docker build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Docker image built successfully!${NC}"

# Create a temporary container to check modules
CONTAINER_ID=$(docker create teprof2:latest)

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Checking TEProf2 Dependencies${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check version
check_version() {
    local tool=$1
    local version_cmd=$2
    local min_version=$3
    local description=$4
    
    echo -e "${YELLOW}Checking ${description}...${NC}"
    
    result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && $version_cmd 2>&1" || echo "NOT FOUND")
    
    if echo "$result" | grep -q "NOT FOUND\|not found\|command not found"; then
        echo -e "${RED}✗ ${description}: NOT FOUND${NC}"
        return 1
    else
        echo -e "${GREEN}✓ ${description}: ${result}${NC}"
        return 0
    fi
}

# Check stringtie
check_version "stringtie" "stringtie --version" "1.3.3" "stringtie >= 1.3.3"
stringtie_status=$?

# Check samtools
check_version "samtools" "samtools --version | head -1" "1.3.1" "samtools >= 1.3.1"
samtools_status=$?

# Check cufflinks
check_version "cufflinks" "cufflinks --version 2>&1 | grep -i cufflinks" "2.2.1" "cufflinks >= 2.2.1"
cufflinks_status=$?

# Check Python 2.7 (from TEProf2.yml)
echo -e "${YELLOW}Checking Python 2.7...${NC}"
python_result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && python --version 2>&1")
if echo "$python_result" | grep -q "2.7"; then
    echo -e "${GREEN}✓ Python 2.7: ${python_result}${NC}"
    python_status=0
else
    echo -e "${RED}✗ Python 2.7: ${python_result}${NC}"
    python_status=1
fi

# Check cPickle module
echo -e "${YELLOW}Checking Python cPickle module...${NC}"
cpickle_result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && python -c 'import cPickle' 2>&1" && echo "OK" || echo "FAILED")
if [ "$cpickle_result" = "OK" ]; then
    echo -e "${GREEN}✓ cPickle module: Available${NC}"
    cpickle_status=0
else
    echo -e "${RED}✗ cPickle module: Not available${NC}"
    cpickle_status=1
fi

# Check pytabix module
echo -e "${YELLOW}Checking Python pytabix module...${NC}"
pytabix_result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && python -c 'import pytabix' 2>&1" && echo "OK" || echo "FAILED")
if [ "$pytabix_result" = "OK" ]; then
    echo -e "${GREEN}✓ pytabix module: Available${NC}"
    pytabix_status=0
else
    echo -e "${RED}✗ pytabix module: Not available${NC}"
    pytabix_status=1
fi

# Check R version
echo -e "${YELLOW}Checking R >= 3.4.1...${NC}"
r_result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && R --version 2>&1 | head -1")
echo -e "${GREEN}✓ R version: ${r_result}${NC}"
r_status=0

# Check R packages
check_r_package() {
    local package=$1
    echo -e "${YELLOW}Checking R package: ${package}...${NC}"
    
    result=$(docker run --rm teprof2:latest bash -c "source activate teprof2 && R --slave -e \"library('${package}')\" 2>&1" && echo "OK" || echo "FAILED")
    
    if [ "$result" = "OK" ]; then
        echo -e "${GREEN}✓ R package ${package}: Available${NC}"
        return 0
    else
        echo -e "${RED}✗ R package ${package}: Not available${NC}"
        return 1
    fi
}

check_r_package "ggplot2"
ggplot2_status=$?

check_r_package "BSgenome.Hsapiens.UCSC.hg38"
bsgenome_status=$?

check_r_package "Xmisc"
xmisc_status=$?

check_r_package "reshape2"
reshape2_status=$?

# Check if TEProf2 bin is in PATH
echo -e "${YELLOW}Checking TEProf2 bin in PATH...${NC}"
path_result=$(docker run --rm teprof2:latest bash -c "echo \$PATH | grep -q 'TEProf2Paper/bin' && echo 'OK' || echo 'FAILED'")
if [ "$path_result" = "OK" ]; then
    echo -e "${GREEN}✓ TEProf2 bin folder: Added to PATH${NC}"
    path_status=0
else
    echo -e "${RED}✗ TEProf2 bin folder: Not in PATH${NC}"
    path_status=1
fi

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Dependency Check Summary${NC}"
echo -e "${YELLOW}========================================${NC}"

failed=0

if [ $stringtie_status -ne 0 ]; then
    echo -e "${RED}✗ stringtie >= 1.3.3${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ stringtie >= 1.3.3${NC}"
fi

if [ $samtools_status -ne 0 ]; then
    echo -e "${RED}✗ samtools >= 1.3.1${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ samtools >= 1.3.1${NC}"
fi

if [ $cufflinks_status -ne 0 ]; then
    echo -e "${RED}✗ cufflinks >= 2.2.1${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ cufflinks >= 2.2.1${NC}"
fi

if [ $python_status -ne 0 ]; then
    echo -e "${RED}✗ Python 2.7${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ Python 2.7${NC}"
fi

if [ $cpickle_status -ne 0 ]; then
    echo -e "${RED}✗ Python cPickle module${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ Python cPickle module${NC}"
fi

if [ $pytabix_status -ne 0 ]; then
    echo -e "${RED}✗ Python pytabix module${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ Python pytabix module${NC}"
fi

echo -e "${GREEN}✓ R >= 3.4.1${NC}"

if [ $ggplot2_status -ne 0 ]; then
    echo -e "${RED}✗ R package: ggplot2${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ R package: ggplot2${NC}"
fi

if [ $bsgenome_status -ne 0 ]; then
    echo -e "${RED}✗ R package: BSgenome.Hsapiens.UCSC.hg38${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ R package: BSgenome.Hsapiens.UCSC.hg38${NC}"
fi

if [ $xmisc_status -ne 0 ]; then
    echo -e "${RED}✗ R package: Xmisc${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ R package: Xmisc${NC}"
fi

if [ $reshape2_status -ne 0 ]; then
    echo -e "${RED}✗ R package: reshape2${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ R package: reshape2${NC}"
fi

if [ $path_status -ne 0 ]; then
    echo -e "${RED}✗ TEProf2 bin in PATH${NC}"
    ((failed++))
else
    echo -e "${GREEN}✓ TEProf2 bin in PATH${NC}"
fi

# Clean up
docker rm $CONTAINER_ID > /dev/null 2>&1 || true

echo -e "${YELLOW}========================================${NC}"
if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All dependencies are correctly installed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}${failed} dependency check(s) failed!${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi