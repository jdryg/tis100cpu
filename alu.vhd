----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:22:04 06/27/2015 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  Generic (WIDTH: integer := 8);
  Port ( I_a, I_b : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
         I_op     : in  STD_LOGIC_VECTOR (1 downto 0);
         O_y      : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end alu;

architecture Behavioral of alu is
begin
  process(I_a, I_b, I_op) begin
    case I_op is
      when "00" => O_y <= I_a + I_b;
      when "01" => O_y <= I_a - I_b;
      when "10" => O_y <= NOT I_a + I_b;
      when others => O_y <= (others => 'X');
    end case;
  end process;
end Behavioral;

