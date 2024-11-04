process COLLECTINPUT {
    tag "$meta.simulation_model"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.70--np112py35_1':
        'biocontainers/biopython:1.70--np112py35_1' }"

    input:
    val(meta)

    output:
    tuple val(meta), path("*_gametes.txt"), emit: gametes
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.simulation_model}"

    """
    echo "Debug: Meta content"
    echo '${meta.inspect()}'

    cat <<EOF > ${prefix}_gametes.txt
    --randomSeed,${meta.seed}
    --attributeAlleleFrequency,${meta.MAF_interacting_associates_attributes}
    --prevalence,${meta.prevalence}
    --heritability,${meta.heritability}
    ${meta.useOddsRatio ? '--useOddsRatio' : ''}
    --quantile_counts,${meta.quantile_counts}
    --population_counts,${meta.population_counts}
    --trycount,${meta.trycount}
    --proportion,${meta.proportion}
EOF

    cat <<EOF > versions.yml
    "${task.process}":
        biopython: \$(python -c "import Bio; print(Bio.__version__)")
EOF

    echo "Debug: Content of ${prefix}_gametes.txt"
    cat ${prefix}_gametes.txt
    echo "Debug: Content of versions.yml"
    cat versions.yml 

    """
}

