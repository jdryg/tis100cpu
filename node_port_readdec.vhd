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
  O_readEnableUp    <= I_readEnable when I_portID = "000" else '0';
  O_readEnableDown  <= I_readEnable when I_portID = "001" else '0';
  O_readEnableLeft  <= I_readEnable when I_portID = "010" else '0';
  O_readEnableRight <= I_readEnable when I_portID = "011" else '0';
end Behavioral;

