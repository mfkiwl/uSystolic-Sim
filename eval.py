import os
import time
import configparser as cp
import simArch.run_nets as r
from absl import flags
from absl import app
import platform

FLAGS = flags.FLAGS
# name of flag | default | explanation
flags.DEFINE_string("systolic", "./config/systolic/scale.cfg", "file to get systolic array architechture from")
flags.DEFINE_string("network", "./config/gemm/test_net/test_net.csv", "consecutive GEMM topologies to read")
flags.DEFINE_string("sram", "./config/sram/sram.cfg", "SRAM configs for hardware simulation (sizes for each SRAM are indicated in systolic file)")
flags.DEFINE_string("dram", "./config/dram/dram.cfg", "DRAM configs for hardware simulation")

class eval:
    def __init__(self, save = False, arch = True, hw = True):
        self.save_space = save
        self.simArch = arch
        self.simHw = hw

    def parse_config(self):
        general = 'general'
        arch_sec = 'architecture_presets'
        config_filename = FLAGS.systolic
        print("Using Architechture from ",config_filename)

        config = cp.ConfigParser()
        config.read(config_filename)

        ## Read the run name
        self.run_name = config.get(general, 'run_name')

        ## Read the architecture_presets
        ## Array height min, max
        ar_h = config.get(arch_sec, 'ArrayHeight').split(',')
        self.ar_h_min = ar_h[0].strip()

        ## Array width min, max
        ar_w = config.get(arch_sec, 'ArrayWidth').split(',')
        self.ar_w_min = ar_w[0].strip()

        ## IFMAP SRAM buffer min, max
        # in KB
        ifmap_sram = config.get(arch_sec, 'IfmapSramSz').split(',')
        self.isram_min = ifmap_sram[0].strip()

        ## FILTER SRAM buffer min, max
        # in KB
        filter_sram = config.get(arch_sec, 'FilterSramSz').split(',')
        self.fsram_min = filter_sram[0].strip()

        ## OFMAP SRAM buffer min, max
        # in KB
        ofmap_sram = config.get(arch_sec, 'OfmapSramSz').split(',')
        self.osram_min = ofmap_sram[0].strip()

        self.dataflow= config.get(arch_sec, 'Dataflow')

        ifmap_offset = config.get(arch_sec, 'IfmapOffset')
        self.ifmap_offset = int(ifmap_offset.strip())

        filter_offset = config.get(arch_sec, 'FilterOffset')
        self.filter_offset = int(filter_offset.strip())

        ofmap_offset = config.get(arch_sec, 'OfmapOffset')
        self.ofmap_offset = int(ofmap_offset.strip())
        
        word_sz_bytes = config.get(arch_sec, 'WordByte')
        self.word_sz_bytes = float(word_sz_bytes.strip())
        
        self.wgt_bw_opt= config.get(arch_sec, 'WeightBwOpt')

        self.topology_file = FLAGS.network

        self.sram_file = FLAGS.sram
        self.dram_file = FLAGS.dram

    def run_eval(self):
        self.parse_config()

        if self.simArch == True:
            self.run_arch()

        if self.simHw == True:
            self.run_hw()

    def run_arch(self):

        df_string = "Weight Stationary"
        assert self.dataflow == 'ws', "Input dataflow for uSystolic should be weight stationary."

        print("====================================================")
        print("************ uSystolic Architecture Sim ************")
        print("====================================================")
        print("Array Size: \t" + str(self.ar_h_min) + "x" + str(self.ar_w_min))
        print("SRAM IFMAP: \t" + str(self.isram_min))
        print("SRAM Filter: \t" + str(self.fsram_min))
        print("SRAM OFMAP: \t" + str(self.osram_min))
        print("Word Bytes: \t" + str(self.word_sz_bytes))
        print("Weight BW Opt: \t" + str(self.wgt_bw_opt))
        print("CSV file path: \t" + self.topology_file)
        print("Dataflow: \t" + df_string)
        print("====================================================")

        net_name = self.topology_file.split('/')[-1].split('.')[0]
        offset_list = [self.ifmap_offset, self.filter_offset, self.ofmap_offset]

        r.run_net(  ifmap_sram_size  = int(self.isram_min), # in KB
                    filter_sram_size = int(self.fsram_min), # in KB
                    ofmap_sram_size  = int(self.osram_min), # in KB
                    array_h = int(self.ar_h_min),
                    array_w = int(self.ar_w_min),
                    net_name = net_name,
                    data_flow = self.dataflow,
                    word_size_bytes = self.word_sz_bytes,
                    wgt_bw_opt = self.wgt_bw_opt,
                    topology_file = self.topology_file,
                    offset_list = offset_list
                )
        self.arch_cleanup()
        print("******* uSystolic Architecture Sim Complete ********")

    def run_hw():

        print("====================================================")
        print("************** uSystolic Hardware Sim **************")
        print("====================================================")
        print("Array Size: \t" + str(self.ar_h_min) + "x" + str(self.ar_w_min))
        print("SRAM IFMAP: \t" + str(self.isram_min))
        print("SRAM Filter: \t" + str(self.fsram_min))
        print("SRAM OFMAP: \t" + str(self.osram_min))
        print("Word Bytes: \t" + str(self.word_sz_bytes))
        print("Weight BW Opt: \t" + str(self.wgt_bw_opt))
        print("CSV file path: \t" + self.topology_file)
        print("Dataflow: \t" + df_string)
        print("====================================================")

        print("********* uSystolic Hardware Sim Complete **********")

    def arch_cleanup(self):
        system = platform.system()
        if system == "Windows":
            # for windows os
            if not os.path.isdir(".\\outputs"):
                os.system("mkdir .\\outputs")

            net_name = self.topology_file.split('/')[-1].split('.')[0]

            path = ".\\output\\eval_out"
            if self.run_name == "":
                path = ".\\outputs\\" + net_name +"_"+ self.dataflow
            else:
                path = ".\\outputs\\" + self.run_name

            if not os.path.isdir(path):
                os.system("mkdir " + path)
            else:
                t = time.time()
                new_path= path + "_" + str(t)
                os.system("move " + path + " " + new_path)
                os.system("mkdir " + path)


            cmd = "move *.csv " + path
            os.system(cmd)

            cmd = "mkdir " + path +"\\layer_wise"
            os.system(cmd)

            cmd = "move " + path +"\\*sram* " + path +"\\layer_wise"
            os.system(cmd)

            cmd = "move " + path +"\\*dram* " + path +"\\layer_wise"
            os.system(cmd)

            if self.save_space == True:
                cmd = "rm -rf " + path +"\\layer_wise"
                os.system(cmd)
        else:
            # for linux os
            if not os.path.exists("./outputs/"):
                os.system("mkdir ./outputs")

            net_name = self.topology_file.split('/')[-1].split('.')[0]

            path = "./output/eval_out"
            if self.run_name == "":
                path = "./outputs/" + net_name +"_"+ self.dataflow
            else:
                path = "./outputs/" + self.run_name

            if not os.path.exists(path):
                os.system("mkdir " + path)
            else:
                t = time.time()
                new_path= path + "_" + str(t)
                os.system("mv " + path + " " + new_path)
                os.system("mkdir " + path)


            cmd = "mv *.csv " + path
            os.system(cmd)

            cmd = "mkdir " + path +"/layer_wise"
            os.system(cmd)

            cmd = "mv " + path +"/*sram* " + path +"/layer_wise"
            os.system(cmd)

            cmd = "mv " + path +"/*dram* " + path +"/layer_wise"
            os.system(cmd)

            if self.save_space == True:
                cmd = "rm -rf " + path +"/layer_wise"
                os.system(cmd)


def main(argv):
    s = eval(save = False, arch = True, hw = True)
    s.run_eval()

if __name__ == '__main__':
  app.run(main)
