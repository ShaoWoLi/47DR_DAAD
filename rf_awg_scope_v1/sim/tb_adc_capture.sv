`timescale 1ns/1ps
module tb_adc_capture;
    reg adc_clk=0, ram_clk=0, host_clk=0;
    always #1.2 adc_clk=~adc_clk;
    initial begin #0.6; forever #4.8 ram_clk=~ram_clk; end
    always #5 host_clk=~host_clk;
    reg adc_resetn=0, ram_resetn=0, host_resetn=0, arm=0;
    reg [127:0] adc_data=0;
    reg [1:0] adc_valid=0;
    reg [17:0] host_word_addr=0;
    reg host_read=0;
    wire [31:0] host_read_data;
    wire host_read_valid, busy, done;
    wire [17:0] captured_samples;
    integer beat, sample, word_index;

    adc_capture #(.CHANNELS(2),.CAPTURE_SAMPLES(16),.SAMPLES_PER_BEAT(4)) dut (
        .adc_clk(adc_clk),.adc_resetn(adc_resetn),
        .ram_clk(ram_clk),.ram_resetn(ram_resetn),
        .host_clk(host_clk),.host_resetn(host_resetn),
        .arm(arm),.adc_data(adc_data),.adc_valid(adc_valid),
        .host_word_addr(host_word_addr),.host_read(host_read),
        .host_read_data(host_read_data),.host_read_valid(host_read_valid),
        .busy(busy),.done(done),.captured_samples(captured_samples)
    );

    task automatic read_word(input [17:0] addr,input [31:0] expected);
        begin
            @(negedge host_clk); host_word_addr=addr; host_read=1;
            @(negedge host_clk); host_read=0;
            wait(host_read_valid); #0.1;
            if(host_read_data!==expected) $fatal(1,"capture read %h got %h expected %h",addr,host_read_data,expected);
            @(negedge host_clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge adc_clk); adc_resetn=1; host_resetn=1; ram_resetn=1;
        repeat(3) @(negedge adc_clk); arm=1;
        wait(busy);
        for(beat=0;beat<4;beat=beat+1) begin
            @(negedge adc_clk);
            for(sample=0;sample<4;sample=sample+1) begin
                adc_data[sample*16 +:16]=beat*4+sample;
                adc_data[64+sample*16 +:16]=100+beat*4+sample;
            end
            adc_valid=2'b11;
        end
        @(negedge adc_clk); adc_valid=0; arm=0;
        wait(done);
        if(captured_samples!=16 || busy) $fatal(1,"capture completion/count mismatch");
        if(dut.capture_fifo.wr_overflow || dut.capture_fifo.rd_underflow)
            $fatal(1,"ADC asynchronous FIFO overflow/underflow");
        for(word_index=0;word_index<8;word_index=word_index+1) begin
            read_word(word_index,((word_index*2+1)<<16)|(word_index*2));
            read_word(18'd32768+word_index,((101+word_index*2)<<16)|(100+word_index*2));
        end
        $display("PASS: ADC four-beat packing, asynchronous quarter-rate RAM write, channel mapping and readback.");
        $finish;
    end
    initial begin #5000; $fatal(1,"ADC capture test timeout"); end
endmodule
