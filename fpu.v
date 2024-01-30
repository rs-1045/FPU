module fpu(a,b,clk,out_flag,opcode,out);

input [15:0]a,b;
input clk;
input [1:0]opcode;

output reg [15:0]out;
output reg [5:0]out_flag;

wire [15:0]addition,subtraction,multiplication,division;
wire [5:0]add_flag;
wire [5:0]sub_flag;
wire [5:0]mul_flag;

// 00-addition
// 01-subtraction
// 10-multiplication
// 11- division

//module mul(a, b, p, snan, qnan, infinity, zero, subnormal, normal);
mul mul1(a,b,multiplication,mul_flag[5],mul_flag[4],mul_flag[3],mul_flag[2],mul_flag[1],mul_flag[0]);

//module sub_add(a,b,s,snan,qnan,infinity,zero,subnormal,normal);
sub_add add1(a,b,addition,add_flag[5],add_flag[4],add_flag[3],add_flag[2],add_flag[1],add_flag[0]);
sub_add sub1(a,b,subtraction,sub_flag[5],sub_flag[4],sub_flag[3],sub_flag[2],sub_flag[1],sub_flag[0]);

//out_flag={Snan,Qnan,Infinity,Zero,Subnormal,Normal}
always @(posedge clk)
begin
	if(opcode==2'b00)	
	begin
		out=addition;
		out_flag[5]=add_flag[5];
		out_flag[4]=add_flag[4];
		out_flag[3]=add_flag[3];
		out_flag[2]=add_flag[2];
		out_flag[1]=add_flag[1];
		out_flag[0]=add_flag[0];
	end 
	
	else if(opcode==2'b01)
	begin
		out=subtraction;
		out_flag[5]=sub_flag[5];
		out_flag[4]=sub_flag[4];
		out_flag[3]=sub_flag[3];
		out_flag[2]=sub_flag[2];
		out_flag[1]=sub_flag[1];
		out_flag[0]=sub_flag[0];
	end 
	
	else if(opcode==2'b10)
	begin
		out=multiplication;
		out_flag[5]=mul_flag[5];
		out_flag[4]=mul_flag[4];
		out_flag[3]=mul_flag[3];
		out_flag[2]=mul_flag[2];
		out_flag[1]=mul_flag[1];
		out_flag[0]=mul_flag[0];
	end
	
	else 
	begin
		out=division;
	end 
	
end
endmodule
