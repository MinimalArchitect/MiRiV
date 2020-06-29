library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

-- ATTENTION: zero flag is only valid on SUB and SLT(U)

entity alu is
	port (
		op	: in  alu_op_type;
		A, B	: in  data_type;
		R	: out data_type;
		Z	: out std_logic
	);
end alu;

architecture rtl of alu is
begin

result : process (op, A, B)
	variable shamt : integer;
begin
	R <= (others => '-');
	case op is
		when ALU_NOP =>
			R <= B;
		when ALU_SLT =>
			if signed(A) < signed(B) then
				R <= (0 => '1', others => '0');
			else
				R <= (others => '0');
			end if;
		when ALU_SLTU =>
			if unsigned(A) < unsigned(B) then
				R <= (0 => '1', others => '0');
			else
				R <= (others => '0');
			end if;
		when ALU_SLL =>
			shamt := to_integer(unsigned(B(4 downto 0)));
			R <= std_logic_vector(shift_left(unsigned(A), shamt));
		when ALU_SRL =>
			shamt := to_integer(unsigned(B(4 downto 0)));
			R <= std_logic_vector(shift_right(unsigned(A), shamt));
		when ALU_SRA =>
			shamt := to_integer(unsigned(B(4 downto 0)));
			R <= std_logic_vector(shift_right(signed(A), shamt));
		when ALU_ADD =>
			R <= std_logic_vector(signed(A) + signed(B));
		when ALU_SUB =>
			R <= std_logic_vector(signed(A) - signed(B));
		when ALU_AND =>
			R <= A and B;
		when ALU_OR =>
			R <= A or B;
		when ALU_XOR =>
			R <= A xor B;
		when others =>
	end case;
end process;

zero_flag : process (op, A, B, R)
begin
	case op is
		when ALU_SUB =>
			if A = B then
				Z <= '1';
			else
				Z <= '0';
			end if;
		when ALU_SLT|ALU_SLTU =>
			Z <= not R(0);
		when others =>
			Z <= '-';
	end case;
end process;

end architecture;
