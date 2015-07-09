-- Added these lines on rev. 42 in order to remove the commit message saying that 
-- there is a bug in the implementation, since the bug has been fixed in the same rev.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity node_port_readmux is
  Generic (WIDTH: integer := 8);
  Port ( I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
         I_dataUp : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_dataDown : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_dataLeft : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_dataRight : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_isDataUpValid : in  STD_LOGIC;
         I_isDataDownValid : in  STD_LOGIC;
         I_isDataLeftValid : in  STD_LOGIC;
         I_isDataRightValid : in  STD_LOGIC;
         O_dataOut : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         O_isDataOutValid : out  STD_LOGIC);
end node_port_readmux;

-- NOTE: The architecture below doesn't support ANY or LAST ports.
architecture Behavioral of node_port_readmux is
begin
  with I_portID select O_dataOut <=
    I_dataUp    when "000",
    I_dataDown  when "001",
    I_dataLeft  when "010",
    I_dataRight when "011",
    (others => '0') when others;

  with I_portID select O_isDataOutValid <=
    I_isDataUpValid    when "000",
    I_isDataDownValid  when "001",
    I_isDataLeftValid  when "010",
    I_isDataRightValid when "011",
    '0' when others;
end Behavioral;
