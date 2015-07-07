library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity instruction_memory is
  port ( I_addr  : in  STD_LOGIC_VECTOR (5 downto 0);
         O_instr : out  STD_LOGIC_VECTOR (31 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
  type IMEM is array (0 to 15) of STD_LOGIC_VECTOR (31 downto 0);
  
  -- Read only memory
  constant ROM: IMEM := (
      X"80800005", 
      X"01100000", 
      X"80800000", 
      X"80900003", 
      X"01900000", 
      X"00A00000", 
      X"01300000", 
      X"84900001", 
      X"CC100006", 
      X"01900000", 
      X"00A00000", 
      X"01300000", 
      X"C010FFF7",
      X"01900000",
      X"00A00000",
      X"01300000"
  );
  
begin
  process(I_addr) begin
    O_instr <= ROM(conv_integer(I_addr));
  end process;
end Behavioral;
