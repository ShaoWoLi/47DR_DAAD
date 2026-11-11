load_features labtools
foreach command {create_hw_axi_txn run_hw_axi wait_on_hw_ila write_hw_ila_data upload_hw_ila_data} {
    puts [help $command]
}
exit
