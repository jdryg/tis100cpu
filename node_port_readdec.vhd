-- Added these lines on rev. 42 in order to remove the commit message saying that 
-- there is a bug in the implementation, since the bug has been fixed in the same rev.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity node_port_readdec is
  Port ( I_clk : in STD_LOGIC;
         I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
         I_readEnable : in  STD_LOGIC;
         O_readEnableUp : out  STD_LOGIC;
         O_readEnableDown : out  STD_LOGIC;
         O_readEnableLeft : out  STD_LOGIC;
         O_readEnableRight : out  STD_LOGIC);
end node_port_readdec;

-- NOTE: The architecture below doesn't support ANY or LAST ports.
architecture Behavioral of node_port_readdec is
begin
  process (I_clk, I_readEnable, I_portID) begin
    O_readEnableUp    <= '0';
    O_readEnableDown  <= '0';
    O_readEnableLeft  <= '0';
    O_readEnableRight <= '0';

    if(rising_edge(I_clk)) then
      if (I_portID = "000") then
        O_readEnableUp  <= I_readEnable;
      elsif (I_portID = "001") then
        O_readEnableDown <= I_readEnable;
      elsif (I_portID = "010") then
        O_readEnableLeft <= I_readEnable;
      elsif (I_portID = "011") then
        O_readEnableRight <= I_readEnable;
      end if;
    end if;
  end process;
end Behavioral;

