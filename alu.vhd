library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  generic (WIDTH: integer := 8);
  port ( I_a, I_b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_op     : in  STD_LOGIC_VECTOR (1 downto 0);
         O_isZero : out STD_LOGIC;
         O_y      : buffer  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end alu;

architecture Behavioral of alu is
begin
  process(I_a, I_b, I_op) 
    variable aluResult : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  begin
    O_isZero <= '0';
    if(I_op = "00") then
      aluResult := I_a + I_b;
      if (aluResult = X"0") then
        O_isZero <= '1';
      end if;
    elsif (I_op = "01") then
      aluResult := I_a - I_b;
      if (aluResult = X"0") then
        O_isZero <= '1';
      end if;
    elsif (I_op = "10") then
      aluResult := NOT I_a + I_b;
      if (aluResult = X"0") then
        O_isZero <= '1';
      end if;
    elsif (I_op = "11") then
      aluResult := (0 => I_a(WIDTH-1), others => '0'); -- SLT: implied comparison with 0
      if (I_a = X"0") then
        O_isZero <= '1';
      end if;
    else 
      aluResult := (others => 'X');
    end if;
    
    O_y <= aluResult;
  end process;
end Behavioral;
