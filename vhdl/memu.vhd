library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
	port (
		-- to mem
		op	: in  memu_op_type;
		A	: in  data_type;
		W	: in  data_type;
		R	: out data_type := (others => '0');

		B	: out std_logic := '0';
		XL	: out std_logic := '0';
		XS	: out std_logic := '0';

		-- to memory controller
		D	: in  mem_in_type;
		M	: out mem_out_type := MEM_OUT_NOP
	);
end memu;

architecture rtl of memu is
begin

memory_output : process(all)
begin
	M.byteena <= (others => '0');
	M.wrdata <= (others => 'X');

	case op.memtype is
		when MEM_B|MEM_BU =>
			case A(1 downto 0) is
				when "00" =>
					M.byteena(3) <= '1';
					M.wrdata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= W(BYTE_WIDTH-1 downto 0);
				when "01" =>
					M.byteena(2) <= '1';
					M.wrdata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= W(BYTE_WIDTH-1 downto 0);
				when "10" =>
					M.byteena(1) <= '1';
					M.wrdata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= W(BYTE_WIDTH-1 downto 0);
				when "11" =>
					M.byteena(0) <= '1';
					M.wrdata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= W(BYTE_WIDTH-1 downto 0);
				when others =>
			end case;
		when MEM_H|MEM_HU =>
			case A(1 downto 0) is
				when "00"|"01" =>
					M.byteena(3 downto 2) <= "11";
					M.wrdata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= W(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
					M.wrdata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= W(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
				when "10"|"11" =>
					M.byteena(1 downto 0) <= "11";
					M.wrdata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= W(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
					M.wrdata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= W(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
				when others =>
			end case;
		when MEM_W =>
			case A(1 downto 0) is
				when "00"|"01"|"10"|"11" =>
					M.byteena(3 downto 0) <= "1111";
					M.wrdata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= W(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
					M.wrdata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= W(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
					M.wrdata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= W(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
					M.wrdata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= W(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
				when others =>
			end case;
		when others =>
	end case;
end process;

result : process(all)
begin
	R <= (others => '0');
	case op.memtype is
		when MEM_B =>
			case A(1 downto 0) is
				when "00" =>
					R <= (others => D.rddata(4*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
				when "01" =>
					R <= (others => D.rddata(3*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
				when "10" =>
					R <= (others => D.rddata(2*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
				when "11" =>
					R <= (others => D.rddata(1*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
				when others =>
			end case;
		when MEM_BU =>
			R <= (others => '0');
			case A(1 downto 0) is
				when "00" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
				when "01" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
				when "10" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
				when "11" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
				when others =>
			end case;

		when MEM_H =>
			case A(1 downto 0) is
				when "00"|"01" =>
					R <= (others => D.rddata(4*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
					R(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= D.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
				when "10"|"11" =>
					R <= (others => D.rddata(2*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
					R(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= D.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
				when others =>
			end case;
		when MEM_HU =>
			R <= (others => '0');
			case A(1 downto 0) is
				when "00"|"01" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
					R(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= D.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
				when "10"|"11" =>
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
					R(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= D.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
				when others =>
			end case;
		when MEM_W =>
			case A(1 downto 0) is
				when "00"|"01"|"10"|"11" =>
					R <= (others => D.rddata(4*BYTE_WIDTH-1));
					R(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) <= D.rddata(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
					R(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) <= D.rddata(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
					R(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) <= D.rddata(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
					R(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) <= D.rddata(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
				when others =>
			end case;
		when others =>
	end case;
end process;

memory_load_exception : process(all)
begin
	XL <= '0';
	if op.memread then
		case op.memtype is
			when MEM_H =>
				case A(1 downto 0) is
					when "01" =>
						XL <= '1';
					when "11" =>
						XL <= '1';
					when others =>
				end case;
			when MEM_HU =>
				case A(1 downto 0) is
					when "01" =>
						XL <= '1';
					when "11" =>
						XL <= '1';
					when others =>
				end case;
			when MEM_W =>
				case A(1 downto 0) is
					when "01" =>
						XL <= '1';
					when "10" =>
						XL <= '1';
					when "11" =>
						XL <= '1';
					when others =>
				end case;
			when others =>
		end case;
	end if;
end process;

memory_store_exception : process(all)
begin
	XS <= '0';
	if op.memwrite then
		case op.memtype is
			when MEM_H =>
				case A(1 downto 0) is
					when "01" =>
						XS <= '1';
					when "11" =>
						XS <= '1';
					when others =>
				end case;
			when MEM_HU =>
				case A(1 downto 0) is
					when "01" =>
						XS <= '1';
					when "11" =>
						XS <= '1';
					when others =>
				end case;
			when MEM_W =>
				case A(1 downto 0) is
					when "01" =>
						XS <= '1';
					when "10" =>
						XS <= '1';
					when "11" =>
						XS <= '1';
					when others =>
				end case;
			when others =>
		end case;
	end if;
end process;

end architecture;



















