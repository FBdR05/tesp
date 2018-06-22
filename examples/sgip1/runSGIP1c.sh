#!/bin/bash
(export FNCS_BROKER="tcp://*:5570" && exec fncs_broker 5 &> broker.log &)
(export FNCS_CONFIG_FILE=eplus.yaml && exec energyplus -w ../../support/energyplus/USA_AZ_Tucson.Intl.AP.722740_TMY3.epw -d output -r ../../support/energyplus/SchoolDualController.idf &> eplus1c.log &)
(export FNCS_CONFIG_FILE=eplus_json.yaml && exec eplus_json 2d 5m School_DualController eplus_SGIP1c_metrics.json &> eplus_json1c.log &)
(export FNCS_FATAL=YES && exec gridlabd -D USE_FNCS -D METRICS_FILE=SGIP1c_metrics.json SGIP1c.glm &> gridlabd1c.log &)
(export FNCS_CONFIG_FILE=SGIP1c_auction.yaml && export FNCS_FATAL=YES && exec python -c "import tesp_support.api as tesp;tesp.auction_loop('SGIP1c_agent_dict.json','SGIP1c')" &> auction1c.log &)
(export FNCS_CONFIG_FILE=pypower.yaml && export FNCS_FATAL=YES && export FNCS_LOG_STDOUT=yes && exec python -c "import tesp_support.api as tesp;tesp.pypower_loop('sgip1_pp.json','SGIP1c')" &> pypower1c.log &)

