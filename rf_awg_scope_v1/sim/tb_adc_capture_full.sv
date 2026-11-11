`timescale 1ns/1ps
// Production beat width/depth. Check every RAM entry and all boundary slots,
// including the upper half of the 128 KiB channel window.
module tb_adc_capture_full;
    reg adc_clk=0, ram_clk=0, host_clk=0;
    always #1.2 adc_clk=~adc_clk;
    initial begin #0.6; forever #4.8 ram_clk=~ram_clk; end
    always #5 host_clk=~host_clk;
    reg adc_resetn=0, ram_resetn=0, host_resetn=0, arm=0;
    reg [383:0] adc_data=0;
    reg [1:0] adc_valid=0;
    reg [17:0] host_word_addr=0;
    reg host_read=0;
    wire [31:0] host_read_data;
    wire host_read_valid, busy, done;
    wire [17:0] captured_samples;
    integer beat, sample, ch, entry, word_index, checks=0;
    adc_capture #(.CHANNELS(2)) dut (
        .adc_clk(adc_clk),.adc_resetn(adc_resetn),
        .ram_clk(ram_clk),.ram_resetn(ram_resetn),
        .host_clk(host_clk),.host_resetn(host_resetn),.arm(arm),
        .adc_data(adc_data),.adc_valid(adc_valid),
        .host_word_addr(host_word_addr),.host_read(host_read),
        .host_read_data(host_read_data),.host_read_valid(host_read_valid),
        .busy(busy),.done(done),.captured_samples(captured_samples)
    );
    task automatic read_word(input integer channel, input integer index);
        reg [15:0] lo,hi;
        reg [31:0] expected;
        begin
            lo=channel*97+index*2; hi=lo+1; expected={hi,lo};
            @(negedge host_clk); host_word_addr=channel*32768+index; host_read=1;
            @(negedge host_clk); host_read=0;
            wait(host_read_valid); #0.1;
            if(host_read_data!==expected)
                $fatal(1,"ADC RAM CH%0d word=%0d got=%08h expected=%08h",channel,index,host_read_data,expected);
            checks=checks+1;
            @(negedge host_clk);
        end
    endtask
    initial begin
        repeat(4) @(negedge adc_clk); adc_resetn=1; host_resetn=1; ram_resetn=1;
        repeat(3) @(negedge adc_clk); arm=1;
        wait(busy);
        for(beat=0;beat<5460;beat=beat+1) begin
            @(negedge adc_clk);
            for(ch=0;ch<2;ch=ch+1)
                for(sample=0;sample<12;sample=sample+1)
                    adc_data[ch*192+sample*16 +:16]=ch*97+beat*12+sample;
            adc_valid=2'b11;
        end
        @(negedge adc_clk); adc_valid=0; arm=0;
        wait(done);
        if(captured_samples!=65520 || busy) $fatal(1,"ADC capture completion/count mismatch");
        if(dut.capture_fifo.wr_overflow || dut.capture_fifo.rd_underflow)
            $fatal(1,"ADC capture FIFO lost data");
        for(ch=0;ch<2;ch=ch+1) begin
            for(word_index=0;word_index<96;word_index=word_index+1) read_word(ch,word_index);
            for(entry=0;entry<1365;entry=entry+1) begin
                read_word(ch,entry*24);
                read_word(ch,entry*24+23);
            end
        end
        $display("PASS: production ADC 65520 samples/channel, 192-to-768-bit packing, all 1365 RAM entries, signed bits, full 128 KiB address window (%0d checks).",checks);
        $finish;
    end
    initial begin #1000000; $fatal(1,"ADC full-depth capture timeout"); end
endmodule
