module sub_add(a,b,s,snan,qnan,infinity,zero,subnormal,normal);
input [15:0]a,b;
output[15:0]s;
output reg snan,qnan,infinity,zero,subnormal,normal;

wire aSnan, aQnan, aInfinity, aZero, aSubnormal, aNormal;
wire bSnan, bQnan, bInfinity, bZero, bSubnormal, bNormal;

wire  [4:0] aExp, bExp;
wire [10:0] aSig, bSig;

integer i;
reg [3:0]sa=0;
reg [10:0]mask=~0;

reg[15:0] stemp;
reg s_sign;
reg [11:0]s_mantissa;
reg [4:0]s_exp;

converter aClass(a, aExp, aSig, aSnan, aQnan, aInfinity, aZero, aSubnormal, aNormal);
converter bClass(b, bExp, bSig, bSnan, bQnan, bInfinity, bZero, bSubnormal, bNormal);

reg diff;// difference of exponent
reg[10:0]temp_mantissa;// shifted mantissa

//----------------------------------------------------------------------------------------------------------------------------

always @(*)
begin
	 {snan, qnan, infinity, zero, subnormal, normal} = 6'b000000;
	 
	 //if any or both operands are zero
	  if(aZero|bZero)
	  begin
		stemp= aZero==1?b:a;
		if(aZero & bZero)
			zero=1;	
	  end
	  
	  // if operand contains qnan
	  else if(aQnan|bQnan)
		begin
			stemp=aQnan==1?a:b;
			qnan=1;
		end
	
		// if operand contains snan
		else if(aSnan|bSnan)
		begin
			stemp=aSnan==1?a:b;
			snan=1;
		end
		
		//if any operand is infinite 
		else if(aInfinity|bInfinity)
		begin
			//stemp=aInfinity==1?a:b;
			if(aInfinity & bInfinity)
			begin
				if(a[15]==b[15])
					begin
						stemp=a;
						infinity=1;
					end	
				else if(a[15]!=b[15])
					begin
						stemp={1'b0,{5{1'b1}},1'b1,9'b00000000};// qnan
						qnan=1;
					end
			 end
			else
					stemp=aInfinity==1?a:b; 
		 end
		//------------------------------------------------------------------------------------------------------------------------
		// for normal and subnormal number 
		else 
		begin
			///////////////////////////////////////////////////////
			if(aExp==bExp)
			begin
				s_exp=aExp;
				if(a[15]==b[15])
				begin
					s_mantissa=aSig+bSig;
					s_sign=a[15];
				end
				else
				begin
					if(aSig>bSig)
					begin
						s_mantissa=aSig-bSig;
						s_sign=a[15];
					end
					
					else
					begin
						s_mantissa=bSig-aSig;
						s_sign=b[15];
					end
				end
			end
			/////////////////////////////////////////////////////////////////////////////////////////
			else if(aExp!=bExp)
			begin
				if(aExp>bExp)// a is bigger than b
				begin
					s_exp=aExp;
					s_sign=a[15];
					diff=aExp-bExp;
					temp_mantissa=bSig>>diff;
					if(a[15]==b[15])
						s_mantissa=aSig+temp_mantissa;
					else
						s_mantissa=aSig-temp_mantissa;
				end
				else if(aExp<bExp)// b is bigger than the a
				begin
					s_exp=bExp;
					s_sign=b[15];
					diff=bExp-aExp;
					temp_mantissa=aSig>>diff;
					if(a[15]==b[15])
						s_mantissa=bSig+temp_mantissa;
					else
						s_mantissa=bSig-temp_mantissa;
				end
			end
	//----------------------------------------------------------------------------------------------		
			if(s_mantissa[11]==1)
			begin
				s_exp=s_exp+1;
				stemp[9:0]=s_mantissa[11:2];
			end
			
        else if ((s_mantissa[11]!=1)&&(s_mantissa[10]!=1))
          begin
            for (i = 8; i > 0; i = i >> 1)
              begin
                if ((s_mantissa & (mask << (11 - i))) == 0)
                  begin
                    s_mantissa = s_mantissa << i;
                    sa = sa | i;
                  end
              end
              
            s_exp = s_exp-sa; 
				stemp[9:0]=s_mantissa[10:1];
          end
	 
//--------------------------------------------------------------------------------------------------------------------			
		stemp[15]=s_sign;
		stemp[14:10]=(s_exp+5'b01111);
		
			
		end
//-------------------------------------------------------------------------------------------------------------------
	if((aExp==bExp)&&(aSig==bSig)&&(a[15]!=b[15]))
	 begin
		stemp={15{1'b0}};
		zero=1;
	 end
//---------------------------------------------------------------------------------------------
end

assign s=stemp;

endmodule
