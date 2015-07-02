----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:49:08 06/27/2015 
-- Design Name: 
-- Module Name:    instruction_memory - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    port ( I_addr  : in  STD_LOGIC_VECTOR (5 downto 0);
           O_instr : out  STD_LOGIC_VECTOR (31 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
begin
  process is 
    -- Max 16 32-bit instructions per IMEM
    type ramtype is array (15 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
	 variable mem: ramtype;
  begin
    -- TODO: Initialize mem

    -- Read mem
	 loop
	   O_instr <= mem(to_integer(unsigned(I_addr)));
		wait on I_addr;
	 end loop;
  end process;
end Behavioral;

