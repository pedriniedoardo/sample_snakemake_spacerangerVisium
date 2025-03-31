# sample rule to launch spaceranger
rule spaceranger:
    input:
        fastq = 'data/{sample}/fastq/', 
        # img = 'data/{sample}/image/{sample}.tif'
    output:
        dir_out = directory('results/spaceranger/{sample}'),
        flag = touch('results/spaceranger/{sample}.stamp')
        # web_summary = 'results/spaceranger/{sample}/outs/web_summary.html'
    conda:'env_spaceranger1'
    log: 'logs/{sample}_spaceranger.log'
    benchmark:'benchmarks/{sample}.txt'
    params:
        # flag = lambda w: config["samples"]["{}".format(w.test)]['param1'],
        # image = '/media/edo/INTENSO/RNAseq/spatial_transcriptomic/MS_Brain/images/01_test.tif',
        wd = directory('results/spaceranger'),
        transcriptome = config['reference_human'],
        param_img = lambda w: config['samples']["{}".format(w.sample)]['param_img'],
        value_img = lambda w: config['samples']["{}".format(w.sample)]['value_img'],
        param_align = lambda w: config['samples']["{}".format(w.sample)]['param_align'],
        value_align = lambda w: config['samples']["{}".format(w.sample)]['value_align'],
        param_probe = lambda w: config['samples']["{}".format(w.sample)]['param_probe'],
        value_probe = lambda w: config['samples']["{}".format(w.sample)]['value_probe'],
        param_slide = lambda w: config['samples']["{}".format(w.sample)]['param_slide'],
        value_slide = lambda w: config['samples']["{}".format(w.sample)]['value_slide'],
        param_area = lambda w: config['samples']["{}".format(w.sample)]['param_area'],
        value_area = lambda w: config['samples']["{}".format(w.sample)]['value_area'],
        param_noBAM = lambda w: config['samples']["{}".format(w.sample)]['param_noBAM']
    resources:
        cpus = 8,
        mem_gb = 32
    threads: 8
    shell:
        '''
        echo "create the result folder for sample: {wildcards.sample}" >> {log}
        mkdir -p {params.wd} &>> {log}
        
        echo "run spaceranger on sample: {wildcards.sample}" >> {log}
        spaceranger count --id={wildcards.sample} \
        --transcriptome={params.transcriptome} \
        --fastqs={input.fastq} \
        --sample={wildcards.sample} \
        --localcores={resources.cpus} \
        --localmem={resources.mem_gb} \
        {params.param_img}{params.value_img} \
        {params.param_slide}{params.value_slide} \
        {params.param_area}{params.value_area} \
        {params.param_align}{params.value_align} \
        {params.param_noBAM} \
        {params.param_probe}{params.value_probe} &>> {log}

        echo "mv the spaceranger result: {wildcards.sample}" >> {log}
        mkdir -p {output.dir_out} &>> {log}
        mv {wildcards.sample} {output.dir_out}/ &>> {log}

        echo "create the stamp of the run: {wildcards.sample}" >> {log}
        touch {output.flag}
        echo "successful run: {wildcards.sample}" >> {output.flag}
        '''

    
    
    