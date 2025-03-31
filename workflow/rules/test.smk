# this is not working
# rule test_sample:
#     input:
#         inp = 'data/input.txt'
#     output:
#         out = 'results/{test}.txt'
#     conda:'bioinfo'
#     log: 'logs/{test}.log'
#     benchmark:'benchmarks/{test}.txt'
#     params:
#         flag = config['samples']['test1']['param1'],
#         n = config['samples']['test1']['value1']
#     resources:
#         cpus = 1
#     threads: 1
#     shell:
#         '''
#         head {params.flag} {params.n} {input} >> {output}
#         '''

# this is working
rule test_sample:
    input:
        inp = 'data/input.txt'
    output:
        out = 'results/{test}.txt'
    conda:'bioinfo'
    log: 'logs/{test}.log'
    benchmark:'benchmarks/{test}.txt'
    params:
        flag = lambda w: config["samples_test"]["{}".format(w.test)]['param1'],
        n = lambda w: config["samples_test"]["{}".format(w.test)]['value1']
    resources:
        cpus = 1
    threads: 1
    shell:
        '''
        head {params.flag} {params.n} {input} >> {output}
        '''