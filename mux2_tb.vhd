--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:46:08 06/27/2015
-- Design Name:   
-- Module Name:   F:/Projects/MyStuff/TIS100/mux2_tb.vhd
-- Project Name:  TIS100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mux2
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY mux2_tb IS
END mux2_tb;
 
ARCHITECTURE behavior OF mux2_tb IS 
  constant MUX_SIZE: integer := 16;
 
  -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT mux2
    GENERIC (WIDTH: integer := MUX_SIZE);
    PORT(
      I_A : IN  std_logic_vector(WIDTH-1 downto 0);
      I_B : IN  std_logic_vector(WIDTH-1 downto 0);
      I_Sel : IN  std_logic;
      O_Y : OUT  std_logic_vector(WIDTH-1 downto 0)
    );
  END COMPONENT;
    

   --Inputs
   signal I_A : std_logic_vector(MUX_SIZE-1 downto 0) := (others => '0');
   signal I_B : std_logic_vector(MUX_SIZE-1 downto 0) := (others => '0');
   signal I_Sel : std_logic := '0';

 	--Outputs
   signal O_Y : std_logic_vector(MUX_SIZE-1 downto 0);

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: mux2 
    GENERIC MAP (WIDTH => MUX_SIZE)
    PORT MAP (
      I_A => I_A,
      I_B => I_B,
      I_Sel => I_Sel,
      O_Y => O_Y
    );

  -- Stimulus process
  stim_proc: process
  begin
    I_A <= X"aaaa";
    I_B <= X"bbbb";
    I_Sel <= '0';
    
    -- If we don't wait for some time at this point, O_Y doesn't have the correct value even though the waves are correct. 
    wait for 10 ns; -- JD: Why is this needed? This isn't a clocked unit. What am I missing?
    assert O_Y = X"aaaa" report "Expected 'AAAA', got wrong value!" severity ERROR;

    wait for 100 ns;
    
    I_Sel <= '1';
    wait for 10 ns; -- JD: Again, why?
    assert O_Y = X"bbbb" report "Expected 'BBBB', got wrong value!" severity ERROR;
    wait;
  end process;
END;
