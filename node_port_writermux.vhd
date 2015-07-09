-- Added these lines on rev. 42 in order to remove the commit message saying that 
-- there is a bug in the implementation, since the bug has been fixed in the same rev.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity node_port_writermux is
  Port ( I_portID : in  STD_LOGIC_VECTOR (2 downto 0);
         I_isDataUpValid : in  STD_LOGIC;
         I_isDataDownValid : in  STD_LOGIC;
         I_isDataLeftValid : in  STD_LOGIC;
         I_isDataRightValid : in  STD_LOGIC;
         O_isDataValid : out  STD_LOGIC);
end node_port_writermux;

architecture Behavioral of node_port_writermux is
begin
  with I_portID select O_isDataValid <=
    I_isDataUpValid    when "000",
    I_isDataDownValid  when "001",
    I_isDataLeftValid  when "010",
    I_isDataRightValid when "011",
    '0' when others;
end Behavioral;

