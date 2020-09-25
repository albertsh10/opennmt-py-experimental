#!/bin/bash
export CUDA_VISIBLE_DEVICES=1 

mkdir -p data/multi30k
wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/training.tar.gz &&  tar -xf training.tar.gz -C data/multi30k && rm training.tar.gz
wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/validation.tar.gz && tar -xf validation.tar.gz -C data/multi30k && rm validation.tar.gz
wget http://www.quest.dcs.shef.ac.uk/wmt17_files_mmt/mmt_task1_test2016.tar.gz && tar -xf mmt_task1_test2016.tar.gz -C data/multi30k && rm mmt_task1_test2016.tar.gz

for l in en de; do for f in data/multi30k/*.$l; do if [[ "$f" != *"test"* ]]; then sed -i "$ d" $f; fi;  done; done
for l in en de; do for f in data/multi30k/*.$l; do perl tools/tokenizer.perl -a -no-escape -l $l -q  < $f > $f.atok; done; done
onmt_preprocess -train_src data/multi30k/train.en.atok -train_tgt data/multi30k/train.de.atok -valid_src data/multi30k/val.en.atok -valid_tgt data/multi30k/val.de.atok -save_data data/multi30k.atok.low -lower

ckpts="multi30k_model_step_300000.pt"
ckpts2="multi30k_model_step_600000.pt"

onmt_train -data data/multi30k.atok.low -save_model ./ckpt/multi30k_model -gpu_ranks 0 -rnn_type SRU -input_feed 0 --train_steps 300000 --valid_steps 30000 --start_decay_steps 20000 --decay_steps 5000 
onmt_translate -gpu 0 -model ./ckpt/$ckpts -src data/multi30k/test2016.en.atok -tgt data/multi30k/test2016.de.atok -replace_unk -verbose -output ./ckpt/multi30k.test.pred.atok
perl tools/multi-bleu.perl data/multi30k/test2016.de.atok < ./ckpt/multi30k.test.pred.atok

onmt_train -data data/multi30k.atok.low -save_model ./ckpt2/multi30k_model -gpu_ranks 0 -rnn_type SRU -input_feed 0 --train_steps 600000 --valid_steps 30000 --start_decay_steps 320000 --decay_steps 5000 --retrain --train_from ./ckpt/$ckpts
onmt_translate -gpu 0 -model ./ckpt2/$ckpts2 -src data/multi30k/test2016.en.atok -tgt data/multi30k/test2016.de.atok -replace_unk -verbose -output ./ckpt2/multi30k.test.pred.atok
perl tools/multi-bleu.perl data/multi30k/test2016.de.atok < ./ckpt2/multi30k.test.pred.atok

