-- Added these lines on rev. 42 in order to remove the commit message saying that 
-- there is a bug in the implementation, since the bug has been fixed in the same rev.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity node_port_writedec is
  Generic (WIDTH : integer := 8);
  Port ( I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
         I_writeEnable : in  STD_LOGIC;
         I_data : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_writeEnableUp : out  STD_LOGIC;
         O_writeEnableDown : out  STD_LOGIC;
         O_writeEnableLeft : out  STD_LOGIC;
         O_writeEnableRight : out  STD_LOGIC;
         O_dataUp : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_dataDown : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_dataLeft : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_dataRight : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end node_port_writedec;

architecture Behavioral of node_port_writedec is
begin
  O_writeEnableUp    <= I_writeEnable when I_portID = "000" else '0';
  O_writeEnableDown  <= I_writeEnable when I_portID = "001" else '0';
  O_writeEnableLeft  <= I_writeEnable when I_portID = "010" else '0';
  O_writeEnableRight <= I_writeEnable when I_portID = "011" else '0';
  
  O_dataUp <= I_data;
  O_dataDown <= I_data;
  O_dataLeft <= I_data;
  O_dataRight <= I_data;
end Behavioral;

