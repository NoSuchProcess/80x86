module ALU(input logic [15:0] a,
           input logic [15:0] b,
           output logic [15:0] out,
           input logic is_8_bit,
           input logic [`MC_ALUOp_t_BITS-1:0] op,
           // verilator lint_off UNUSED
           // verilator lint_off UNDRIVEN
           input logic [15:0] flags_in,
           output logic [15:0] flags_out);
           // verilator lint_on UNUSED
           // verilator lint_on UNDRIVEN

assign flags_out[PF_IDX] = ~^out[7:0];
assign flags_out[AF_IDX] = a[4] ^ b[4] ^ out[4];
assign flags_out[SF_IDX] = out[is_8_bit ? 7 : 15];
assign flags_out[ZF_IDX] = is_8_bit ? ~|out[7:0] : ~|out;

task do_add;
input [15:0] _a;
input [15:0] _b;
input _carry_in;
begin
    if (!is_8_bit) begin
        {flags_out[CF_IDX], out} = _a + _b + {15'b0, _carry_in};
        flags_out[OF_IDX] = ~(_a[15] ^ _b[15]) & (out[15] ^ _b[15]);
    end else begin
        out = a + b + {15'b0, _carry_in};
        flags_out[CF_IDX] = _a[8] ^ _b[8] ^ out[8];
        flags_out[OF_IDX] = ~(_a[7] ^ _b[7]) & (out[7] ^ _b[7]);
    end
end
endtask

task do_and;
input [15:0] _a;
input [15:0] _b;
begin
    out = _a & _b;
    flags_out[CF_IDX] = 1'b0;
end
endtask

always_comb begin
    case (op)
    ALUOp_SELA: out = a;
    ALUOp_SELB: out = b;
    ALUOp_ADD: do_add(a, b, 1'b0);
    ALUOp_ADC: do_add(a, b, flags_in[CF_IDX]);
    ALUOp_AND: do_and(a, b);
    // verilator coverage_off
    default: begin
`ifdef verilator
        invalid_opcode_assertion: assert(0) begin
            $display("oops!");
        end
`endif // verilator
    end
    // verilator coverage_on
    endcase
end

endmodule
