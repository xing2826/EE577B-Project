module tb_ring();
  reg clk;
  reg reset;

  reg net_so1;
  reg [63:0] net_do1;
  reg net_ri1;
  wire net_si1;
  wire net_ro1;
  wire net_ploarity1;
  wire [63:0] net_di1;

  reg net_so2;
  reg [63:0] net_do2;
  reg net_ri2;
  wire net_si2;
  wire net_ro2;
  wire net_ploarity2;
  wire [63:0] net_di2;

  reg net_so3;
  reg [63:0] net_do3;
  reg net_ri3;
  wire net_si3;
  wire net_ro3;
  wire net_ploarity3;
  wire [63:0] net_di3;

  reg net_so4;
  reg [63:0] net_do4;
  reg net_ri4;
  wire net_si4;
  wire net_ro4;
  wire net_ploarity4;
  wire [63:0] net_di4;
	
  ring dut_ring(
    .clk(clk),
    .reset(reset),

    .net_so1(net_so1),
    .net_do1(net_do1),
    .net_ri1(net_ri1),
    .net_si1(net_si1),
    .net_ro1(net_ro1),
    .net_ploarity1(net_plority1),
    .net_di1(net_di1),

    .net_so2(net_so2),
    .net_do2(net_do2),
    .net_ri2(net_ri2),
    .net_si2(net_si2),
    .net_ro2(net_ro2),
    .net_ploarity2(net_plority2),
    .net_di2(net_di2),

    .net_so3(net_so3),
    .net_do3(net_do3),
    .net_ri3(net_ri3),
    .net_si3(net_si3),
    .net_ro3(net_ro3),
    .net_ploarity3(net_plority3),
    .net_di3(net_di3),

    .net_so4(net_so4),
    .net_do4(net_do4),
    .net_ri4(net_ri4),
    .net_si4(net_si4),
    .net_ro4(net_ro4),
    .net_ploarity4(net_plority4),
    .net_di4(net_di4));
  
  initial begin
    reset <= 1;
    clk <= 0;
    net_ri1 <= 1;
    net_ri2 <= 1;
    net_ri3 <= 1;
    net_ri4 <= 1;
    #8;
    reset <= 0;
  end
  
  always #2 clk <= ~clk;
 
  initial begin
    #10;
    net_so1 <= 1; 
    net_do1 <= 64'h30_0f_3412_ffffffff;
    #0.5;
    net_so1 <=0;
    #64;
    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
  
endmodule