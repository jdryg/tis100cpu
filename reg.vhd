library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
  Generic(WIDTH: integer := 8);
  Port (
    I_clk : in  STD_LOGIC;
    I_reset : in  STD_LOGIC;
    I_dataIn : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end reg;

architecture Behavioral of reg is
begin
  process (I_clk) begin
    if (rising_edge(I_clk)) then
      if(I_reset = '1') then
        O_dataOut <= (others => '0');
      else
        O_dataOut <= I_dataIn;
      end if;
    end if;
  end process;
end Behavioral;

