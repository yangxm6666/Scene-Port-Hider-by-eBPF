if(NOT BPFTOOL)
    message(FATAL_ERROR "BPFTOOL is not set")
endif()

if(NOT INPUT)
    message(FATAL_ERROR "INPUT is not set")
endif()

if(NOT OUTPUT)
    message(FATAL_ERROR "OUTPUT is not set")
endif()

execute_process(
    COMMAND "${BPFTOOL}" gen skeleton "${INPUT}"
    RESULT_VARIABLE result
    OUTPUT_FILE "${OUTPUT}"
    ERROR_VARIABLE stderr
)

if(NOT result EQUAL 0)
    file(REMOVE "${OUTPUT}")
    message(FATAL_ERROR "bpftool gen skeleton failed: ${stderr}")
endif()
