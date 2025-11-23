process DIGENOME {
    tag "$meta.id"
    label 'process_single'

    container 'drfrederickmappin/digenome:latest'

    input:
    tuple val(meta), path(bam)
    val quality_threshold
    val overhang

    output:
    tuple val(meta), path("*.csv"), emit: csv, optional: true
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Run digenome analysis
    run_digenome.sh ${bam} -G ${overhang} -q ${quality_threshold} --csv ${prefix}.csv
    
    # Check if CSV was created
    if [ ! -f "${prefix}.csv" ]; then
        echo "ERROR: Digenome failed - no CSV output" >&2
        exit 1
    fi
    
    # Verify CSV was created by digenome
    if [ ! -f "${prefix}.csv" ]; then
        echo "ERROR: Digenome analysis failed to create ${prefix}.csv" >&2
        exit 1
    fi
    
    # Create a log file for tracking  
    echo "Digenome analysis completed for ${bam}" > ${prefix}_digenome.log
    echo "Quality threshold used: ${quality_threshold}" >> ${prefix}_digenome.log
    
    # Verify CSV was created
    if [ -f "${prefix}.csv" ]; then
        SITE_COUNT=\$(tail -n +2 "${prefix}.csv" | wc -l)
        echo "CSV file created with \$SITE_COUNT cleavage sites" >> ${prefix}_digenome.log
        echo "✅ Analysis complete: \$SITE_COUNT sites detected"
    else
        echo "⚠️ No cleavage sites detected" >> ${prefix}_digenome.log
        echo "Warning: No cleavage sites detected" > ${prefix}.csv
    fi
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        digenome: v1.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.csv
    touch ${prefix}_digenome.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        digenome: v1.0
    END_VERSIONS
    """
}
