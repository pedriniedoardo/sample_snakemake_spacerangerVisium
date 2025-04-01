# sample rule to launch spaceranger
rule runSpaceranger:
    input:
        fastqs = lambda w: config['SAMPLES']["{}".format(w.sample)]['fastq']
    conda:
        config['env_spaceranger']
    output:
        output = config["out_location"] + "spaceranger/{sample}_finished.log",
        folder = directory(config["out_location"] + "spaceranger/{sample}")
    log:
        'logs/{sample}/runSpaceranger.log'
    benchmark:
        'benchmarks/{sample}/runSpaceranger.txt'
    params:
        transcriptome = config['transcriptome'],
        param_img = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_img'],
        value_img = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_img'],
        param_cytimg = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_cytimg'],
        value_cytimg = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_cytimg'],
        param_align = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_align'],
        value_align = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_align'],
        param_probe = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_probe'],
        value_probe = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_probe'],
        param_slide = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_slide'],
        value_slide = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_slide'],
        param_area = lambda w: config['SAMPLES']["{}".format(w.sample)]['param_area'],
        value_area = lambda w: config['SAMPLES']["{}".format(w.sample)]['value_area'],
        param_BAM = config['BAM_param'],
        value_BAM = config['BAM_flag'],
        outs = directory(config["out_location"] + "spaceranger/{sample}")
    resources:
        cpus = config["spaceranger_cpus"],
        mem_gb = config["spaceranger_mem_gb"]
    threads: config["spaceranger_cpus"]
    shell:
        '''
        echo "create the result folder for sample: {wildcards.sample}" >> {log}
        mkdir -p {params.outs} &>> {log}
        
        echo "run spaceranger on sample: {wildcards.sample}" >> {log}
        spaceranger count --id={wildcards.sample} \
        --transcriptome={params.transcriptome} \
        --fastqs={input.fastqs} \
        --sample={wildcards.sample} \
        --localcores={resources.cpus} \
        --localmem={resources.mem_gb} \
        --output-dir={params.outs} \
        {params.param_cytimg}{params.value_cytimg} \
        {params.param_img}{params.value_img} \
        {params.param_slide}{params.value_slide} \
        {params.param_area}{params.value_area} \
        {params.param_align}{params.value_align} \
        {params.param_BAM}{params.value_BAM} \
        {params.param_probe}{params.value_probe} &>> {log}

        echo "create the stamp of the run: {wildcards.sample}" >> {log}
        touch {output.output}
        echo "successful run: {wildcards.sample}" >> {output.output}
        '''

rule moveSpacerangerSummary:
    '''
    This is the rule to move the outputs of interest.
    '''
    input:
        spaceranger_summary = rules.runSpaceranger.output.output
    conda:
        config['env_spaceranger']
    output:
        summary = config["out_location"] + "web_summaries/{sample}_web_summary.html",
    log:
        'logs/{sample}/02_MoveSpaceranger_summary.log'
    benchmark:
        'benchmarks/{sample}/02_MoveSpaceranger_summary.txt'
    resources:
        mem_mb = 250,
        cpus = 1
    threads: 1
    params:
        wd_summary = config["out_location"] + 'spaceranger/{sample}/outs/web_summary.html',
        bam = config["out_location"] + "spaceranger/{sample}/outs/possorted_genome_bam.bam"
    shell:
        '''
        # copy
        echo "copy summary <{wildcards.sample}>" >> {log}

        # copy the web summary from the output in an individula folder
        cp {params.wd_summary} {output.summary} >> {log}

        echo "summary copied <{wildcards.sample}>" >> {log}
        '''

rule runMultiqc1:
    '''
    This rule allow to run the multiqc on the final folder.
    Currently it is set to run after spaceranger. this is the only step to grep some outputs.
    '''
    input:
        # this is needed to trigger it after the generation of the outputs
        input_file = expand(rules.moveSpacerangerSummary.output.summary, sample=config['SAMPLES'])
    conda:
        config['env_bioinfo']
    output:
        html = config["out_location"] + "multiQC/multiqc_report.html"
    log:
        'logs/multiqc.log'
    benchmark:
        'benchmarks/multiqc.txt'
    resources:
        mem_gb = 4,
        cpus = 2
    threads: 2
    params:
        folder_in = config["out_location"] + "spaceranger/",
        folder_out = config["out_location"] + "multiQC/",
    shell:
        '''
        echo "start multiqc" >> {log}
        multiqc {params.folder_in} -o {params.folder_out}
        echo "end multiqc" >> {log}
        '''
