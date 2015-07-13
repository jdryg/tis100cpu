library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  generic (WIDTH: integer := 8);
  port ( I_a, I_b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_op     : in  STD_LOGIC_VECTOR (2 downto 0);
         O_isZero : out STD_LOGIC;
         O_y      : buffer  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end alu;

architecture Behavioral of alu is
begin
  process(I_a, I_b, I_op) 
    variable aluResult : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    variable checkForZero : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
  begin
    if(I_op = "000") then
      -- ADD 
      aluResult := I_a + I_b;
      checkForZero := aluResult;
    elsif (I_op = "001") then
      -- SUB
      aluResult := I_a - I_b;
      checkForZero := aluResult;
    elsif (I_op = "010") then
      -- NOT A + B
      aluResult := NOT I_a + I_b;
      checkForZero := aluResult;
    elsif (I_op = "011") then
      -- SLT
      aluResult := (0 => I_a(WIDTH-1), others => '0'); -- SLT: implied comparison with 0
      checkForZero := I_a; -- isZero is set based on the value of I_a
    elsif (I_op = "100") then
      -- Inverse SUB
      aluResult := I_b - I_a;
      checkForZero := aluResult;
    else
      aluResult := (others => 'X');
      checkForZero := (others => 'X');
    end if;

    -- Outputs
    O_y <= aluResult;

    if(checkForZero = X"0") then
      O_isZero <= '1';
    else
      O_isZero <= '0';
    end if;
  end process;
end Behavioral;
