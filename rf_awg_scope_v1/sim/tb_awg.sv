`timescale 1ns/1ps
module tb_awg;
    reg hc=0,sc=0,rc=0; always #5 hc=~hc; always #8 sc=~sc; always #32 rc=~rc;
    reg hr=0,sr=0,rr=0,configured=0;
    reg [31:0] awaddr=0,wdata=0,araddr=0;
    reg [3:0] wstrb=15;
    reg awvalid=0,wvalid=0,bready=0,arvalid=0,rready=0;
    wire awready,wready,bvalid,arready,rvalid;
    wire [1:0] bresp,rresp;
    wire [31:0] rdata;
    wire [2047:0] data;
    wire [7:0] valid,active,faults;
    reg [7:0] ready=255;
    wire running,started,capture,psready;
    wire [31:0] wraps;
    awg_subsystem dut(
        .host_clk(hc),.host_resetn(hr),.sample_clk(sc),.sample_resetn(sr),
        .ram_clk(rc),.ram_resetn(rr),.ps_config_done(configured),
        .s_awaddr(awaddr),.s_awvalid(awvalid),.s_awready(awready),
        .s_wdata(wdata),.s_wstrb(wstrb),.s_wvalid(wvalid),.s_wready(wready),
        .s_bresp(bresp),.s_bvalid(bvalid),.s_bready(bready),
        .s_araddr(araddr),.s_arvalid(arvalid),.s_arready(arready),
        .s_rdata(rdata),.s_rresp(rresp),.s_rvalid(rvalid),.s_rready(rready),
        .dac_data(data),.dac_valid(valid),.dac_ready(ready),.running(running),
        .start_marker(started),.capture_marker(capture),.active(active),
        .fault_channels(faults),.wrap_count(wraps),.ps_ready(psready)
    );
    localparam R=32'h90200000;
    task automatic write_word(input [31:0] addr,input [31:0] value,input [3:0] strobe,input [1:0] expected);
        reg [1:0] held;
        begin
            @(negedge hc); awaddr=addr; awvalid=1;
            do @(posedge hc); while(!awready);
            @(negedge hc); awvalid=0;
            // Deliberately separate AW and W; AXI-Lite does not require simultaneity.
            repeat(2) @(negedge hc);
            wdata=value; wstrb=strobe; wvalid=1;
            do @(posedge hc); while(!wready);
            @(negedge hc); wvalid=0;
            wait(bvalid); held=bresp;
            repeat(3) begin @(negedge hc); if(!bvalid || bresp!==held) $fatal(1,"B changed under backpressure"); end
            if(bresp!==expected) $fatal(1,"Bad BRESP at %h: %h expected %h",addr,bresp,expected);
            bready=1; @(negedge hc); bready=0;
        end
    endtask
    task automatic read_word(input [31:0] addr,input [31:0] expected,input [1:0] response);
        reg [31:0] held;
        begin
            @(negedge hc); araddr=addr; arvalid=1;
            do @(posedge hc); while(!arready);
            @(negedge hc); arvalid=0;
            wait(rvalid); held=rdata;
            repeat(3) begin @(negedge hc); if(!rvalid || rdata!==held) $fatal(1,"R changed under backpressure"); end
            if(rdata!==expected || rresp!==response) $fatal(1,"Bad read %h: %h resp %h expected %h",addr,rdata,rresp,expected);
            rready=1; @(negedge hc); rready=0;
        end
    endtask
    task automatic command(input [31:0] value);
        begin
            write_word(R+8,value,15,0);
            wait(!dut.control.busy);
            repeat(4) @(negedge hc);
        end
    endtask
    integer n, ch, lane;
    reg [255:0] expected_beat;
    reg [255:0] held_data;
    reg [255:0] source_held;
    reg source_stalled;
    reg [255:0] beat0,beat1,beat2,beat3;
    initial begin
        #200; @(negedge hc); hr=1; sr=1; rr=1;
        read_word(R,32'h41574731,0);
        write_word(R+8,2,15,2); // Cannot start before PS clocks/MTS are ready.
        configured=1; repeat(8) @(negedge hc);
        for(n=0;n<32;n=n+1) write_word(32'h90040000+4*n,32'h12340000+n,15,0);
        for(n=0;n<32;n=n+1) read_word(32'h90040000+4*n,32'h12340000+n,0);
        write_word(32'h90100000,32'h12340000,15,2);
        read_word(32'h90100000,0,2);
        write_word(32'h90040000,32'h12340000,15,0);
        write_word(32'h90040000,32'h000000aa,1,0);
        read_word(32'h90040000,32'h123400aa,0);
        read_word(32'h90210000,0,2);
        write_word(R+12,0,15,2);
        write_word(R+12,1025,15,2);
        write_word(R+12,2048,15,2);
        write_word(R+12,1024,15,0);
        read_word(R+12,1024,0);
        write_word(R+12,1,15,0);
        write_word(R+16,4,15,0); // Only channel 2, exercises disabled channel zero.
        beat0={32'h12340007,32'h12340006,32'h12340005,32'h12340004,32'h12340003,32'h12340002,32'h12340001,32'h123400aa};
        beat1={32'h1234000f,32'h1234000e,32'h1234000d,32'h1234000c,32'h1234000b,32'h1234000a,32'h12340009,32'h12340008};
        beat2={32'h12340017,32'h12340016,32'h12340015,32'h12340014,32'h12340013,32'h12340012,32'h12340011,32'h12340010};
        beat3={32'h1234001f,32'h1234001e,32'h1234001d,32'h1234001c,32'h1234001b,32'h1234001a,32'h12340019,32'h12340018};
        fork
            command(2);
            begin
                @(posedge started); #1;
                for(n=0;n<20;n=n+1) begin
                    @(negedge sc);
                    case(n%4)
                        0: expected_beat=beat0;
                        1: expected_beat=beat1;
                        2: expected_beat=beat2;
                        3: expected_beat=beat3;
                    endcase
                    if(data[512 +: 256] !== expected_beat) $fatal(1,"Loop sequence error %0d got %h expected %h qcount=%d chunk=%d ram=%h sdata=%h mem=%h wb=%d rb=%d gm=%h gv=%b sl_occ=%d en=%b run=%b active=%h state=%d ren=%b ready=%b",n,data[512 +:256],expected_beat,dut.channel[2].gearbox.wr_bin-dut.channel[2].gearbox.rd_bin,dut.channel[2].gearbox.chunk_index,dut.ram_data[2048 +:1024],dut.player_axis_data[2048 +:1024],dut.channel[2].gearbox.storage[0],dut.channel[2].gearbox.wr_bin,dut.channel[2].gearbox.rd_bin,dut.gearbox_data[512 +:256],dut.gearbox_valid[2],dut.dac_axis_slice[2].tx_slice.occupancy,dut.channel[2].gearbox.enable_sync,running,active,dut.player.state,dut.ram_en[2],dut.player_axis_ready[2]);
                    if(data[255:0]!==0 || active!==4 || valid!==255) $fatal(1,"Channel mapping/valid error");
                end
            end
        join
        if(wraps==0) $fatal(1,"Nonzero leader wrap count missing");
        write_word(32'h90040000,0,15,2); // A running wave must not be modified.
        write_word(R+12,1,15,2);
        command(8);
        // Backpressure must hold the current sample, set a fault and stop peers.
        @(negedge sc); ready[2]=0; held_data=data[512 +: 256];
        source_stalled=0;
        #1;
        if(!dut.player_axis_ready[2]) $fatal(1,"Downstream ready reached AWG combinationally");
        repeat(100) begin
            @(negedge sc);
            if(data[512 +: 256]!==held_data) $fatal(1,"Stalled DAC output changed");
            if(!dut.player_axis_ready[2]) begin
                if(!source_stalled) begin
                    source_held=dut.player_axis_data[512 +: 256];
                    source_stalled=1;
                end else if(dut.player_axis_data[512 +: 256]!==source_held)
                    $fatal(1,"AWG source changed data while AXI stalled");
            end
        end
        if(faults!==4 || !running || !source_stalled) $fatal(1,"Stall not reported/drained correctly faults=%h running=%b source_stalled=%b valid=%b data_valid=%b downstream_ready=%b state=%d",faults,running,source_stalled,valid,dut.gearbox_data_valid,dut.dac_ready,dut.player.state);
        ready[2]=1; #1;
        if(dut.player_axis_data[512 +: 256]!==source_held)
            $fatal(1,"AWG source changed the pending beat on ready reassertion");
        wait(!running);
        repeat(6) @(negedge hc);
        write_word(R+8,2,15,2); // Fault needs explicit clear before restart.
        command(4);
        write_word(R+12,1,15,0);
        fork
            command(2);
            begin
                @(posedge started); #1;
                for(n=0;n<8;n=n+1) begin
                    @(negedge sc);
                    case(n%4)
                        0: expected_beat=beat0;
                        1: expected_beat=beat1;
                        2: expected_beat=beat2;
                        3: expected_beat=beat3;
                    endcase
                    if(data[512 +:256] !== expected_beat)
                        $fatal(1,"Length-one RAM word did not repeat all four 256-bit quarters at beat %0d",n);
                end
            end
        join
        command(1);
        if(data!==0 || running) $fatal(1,"Stop did not return to zeros");
        read_word(32'h90040000,32'h123400aa,0);
        // Unique data in every lane of every channel catches bus concatenation,
        // bank-address and simultaneous-start mistakes hidden by single-channel tests.
        for(ch=0;ch<8;ch=ch+1)
            for(n=0;n<32;n=n+1)
                write_word(32'h90000000+ch*32'h20000+4*n,32'h10000000+(ch<<16)+n,15,0);
        write_word(R+12,1,15,0);
        write_word(R+16,255,15,0);
        fork
            command(2);
            begin
                @(posedge started); #1;
                for(n=0;n<20;n=n+1) begin
                    @(negedge sc);
                    for(ch=0;ch<8;ch=ch+1) begin
                        for(lane=0;lane<8;lane=lane+1)
                            expected_beat[lane*32 +:32]=32'h10000000+(ch<<16)+8*(n%4)+lane;
                        if(data[ch*256 +:256]!==expected_beat || active!==255)
                            $fatal(1,"Eight-channel sequence mismatch CH%0d beat%0d",ch,n);
                    end
                end
            end
        join
        command(1);
        // A converter that never becomes ready must fail START, not hang it.
        @(negedge sc); ready[7]=0;
        command(2);
        if(running || faults!==128 || dut.control.result_sync!==2)
            $fatal(1,"START readiness timeout was not reported");
        ready[7]=1;
        command(4);
        $display("PASS: AXI split channels/backpressure, byte writes/readback, address validation, CDC commands, loops, write lock, fault drain, restart, stop.");
        $display("PASS: All eight channels with unique lane data and simultaneous start; START timeout.");
        $finish;
    end
    initial begin #2000000; $fatal(1,"Watchdog timeout"); end
endmodule
