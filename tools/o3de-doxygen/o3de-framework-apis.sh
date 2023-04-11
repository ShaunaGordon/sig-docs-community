#!/bin/bash

source ./o3de-api-functions.sh
source ./config.sh

# Path to output generated files
OUTPUT_DIRECTORY=${O3DEORG_PATH}/static/docs/api/frameworks  

# Path to source code
FRAMEWORKS=${O3DE_PATH}/Code/Framework

# Frameworks API landing page template
LANDING_TEMPLATE=framework_index.md

# File to output LANDING_TEMPLATE
OUTPUT_TOC=${O3DEORG_PATH}/content/docs/api/frameworks/_index.md

# Create Frameworks API landing page (https://www.o3de.org/docs/api/frameworks/)
# If parent directories don't exist, create them
if [ ! -e "${OUTPUT_TOC%%/*}" ]; then
    mkdir -p "${OUTPUT_TOC%%/*}"
fi
cp ${LANDING_TEMPLATE} ${OUTPUT_TOC}

# Generate a set of API docs for each framework
for framework_path in `ls -1d ${FRAMEWORKS}/*/ `; do

    # Configure and run Doxygen

    framework=`basename ${framework_path}`

    echo "* [${framework}](/docs/api/frameworks/${framework})" >> ${OUTPUT_TOC}

    config_file=`mktemp`
    index="index.md"

    echo \
    "
    Welcome to the **Open 3D Engine (O3DE)** API Reference for the **${framework}** framework!

    $TOC_PATTERN

    Return to the [Frameworks API Reference](/docs/api/frameworks) index page. 

    " > $index

    main_config="core-api-doxygen.config"
    if [ -e "${framework}.doxygen" ]; then
        main_config="${framework}.doxygen"
    fi

    cat $main_config >> $config_file
    echo PROJECT_NAME=\"Open 3D Engine ${framework} API Reference\" >> $config_file
    echo OUTPUT_DIRECTORY=${OUTPUT_DIRECTORY} >> $config_file
    echo INPUT=${framework_path} ${index} >> $config_file
    echo HTML_OUTPUT=${framework} >> $config_file
    echo STRIP_FROM_PATH=$O3DE_PATH >> $config_file

    echo "${framework}: Using config ${config_file}, landing page ${index}"
    doxygen $config_file

    # Post-process generated files
    
    generate_toc "${OUTPUT_DIRECTORY}/${framework}" "${framework}"

done