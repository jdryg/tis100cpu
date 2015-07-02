library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2 is
  generic (WIDTH: integer := 8);
  port ( I_A, I_B : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_Sel    : in  STD_LOGIC;
         O_Y      : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end mux2;

architecture Behavioral of mux2 is
begin
  O_Y <= I_B when I_Sel = '1' else I_A;
end Behavioral;
