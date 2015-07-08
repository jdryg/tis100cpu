--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:51:44 07/08/2015
-- Design Name:   
-- Module Name:   F:/Projects/MyStuff/TIS100/next_pc_tb.vhd
-- Project Name:  TIS100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: next_pc
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
 
ENTITY next_pc_tb IS
END next_pc_tb;
 
ARCHITECTURE behavior OF next_pc_tb IS 
  -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT next_pc
  PORT(
    I_srcA_isPort : IN  std_logic;
    I_dst_isPort : IN  std_logic;
    I_pr_isDataOutValid : IN  std_logic;
    I_pw_isDataOutValid : IN  std_logic;
    I_regB_data : IN  std_logic_vector(15 downto 0);
    I_imm : IN  std_logic_vector(15 downto 0);
    I_containsIMM : IN  std_logic;
    I_isJump : IN  std_logic;
    I_jmpCondition : IN  std_logic_vector(2 downto 0);
    I_isZero : IN  std_logic;
    I_isLessThan : IN  std_logic;
    I_PC : IN  std_logic_vector(15 downto 0);
    O_NewPC : OUT  std_logic_vector(15 downto 0)
  );
  END COMPONENT;
    

  --Inputs
  signal I_srcA_isPort : std_logic := '0';
  signal I_dst_isPort : std_logic := '0';
  signal I_pr_isDataOutValid : std_logic := '0';
  signal I_pw_isDataOutValid : std_logic := '0';
  signal I_regB_data : std_logic_vector(15 downto 0) := (others => '0');
  signal I_imm : std_logic_vector(15 downto 0) := (others => '0');
  signal I_containsIMM : std_logic := '0';
  signal I_isJump : std_logic := '0';
  signal I_jmpCondition : std_logic_vector(2 downto 0) := (others => '0');
  signal I_isZero : std_logic := '0';
  signal I_isLessThan : std_logic := '0';
  signal I_PC : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
  signal O_NewPC : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  uut: next_pc PORT MAP (
    I_srcA_isPort => I_srcA_isPort,
    I_dst_isPort => I_dst_isPort,
    I_pr_isDataOutValid => I_pr_isDataOutValid,
    I_pw_isDataOutValid => I_pw_isDataOutValid,
    I_regB_data => I_regB_data,
    I_imm => I_imm,
    I_containsIMM => I_containsIMM,
    I_isJump => I_isJump,
    I_jmpCondition => I_jmpCondition,
    I_isZero => I_isZero,
    I_isLessThan => I_isLessThan,
    I_PC => I_PC,
    O_NewPC => O_NewPC
  );

  -- Stimulus process
  stim_proc: process
  begin
    -- Initial state test. With all inputs set to 0 O_NewPC should be 1
    wait for 10 ns;
    assert O_NewPC = X"0001" report "Initial state test failed." severity error;
    
    -- Port read test (port not ready yet)
    I_srcA_isPort <= '1';
    wait for 10 ns;
    assert O_NewPC = X"0000" report "Port read test with port not ready failed" severity error;
    
    -- Port is ready now
    I_pr_isDataOutValid <= '1';
    wait for 10 ns;
    assert O_NewPC = X"0001" report "Port read test with port ready failed" severity error;
    
    -- Revert to the initial state
    I_srcA_isPort <= '0';
    I_pr_isDataOutValid <= '0';
    
    -- Port write test (port not ready yet)
    I_dst_isPort <= '1';
    wait for 10 ns;
    assert O_NewPC = X"0000" report "Port write test with port not ready failed" severity error;
    
    -- Port is ready now
    I_pw_isDataOutValid <= '1';
    wait for 10 ns;
    assert O_NewPC = X"0001" report "Port write test with port ready failed" severity error;

    -- Revert to the initial state
    I_dst_isPort <= '0';
    I_pw_isDataOutValid <= '0';
    
    -- JLZ with false condition
    I_imm <= X"0005";
    I_containsIMM <= '1';
    I_isJump <= '1';
    I_isZero <= '1';
    I_isLessThan <= '0';
    I_jmpCondition <= "010";
    wait for 10 ns;
    assert O_NewPC = X"0001" report "JLZ with false condition failed" severity error;
    
    -- JLZ with true condition
    I_isZero <= '0';
    I_isLessThan <= '1';
    wait for 10 ns;
    assert O_NewPC = X"0005" report "JLZ with true condition failed" severity error;
    
    -- JGZ with false condition
    I_jmpCondition <= "001";
    wait for 10 ns;
    assert O_NewPC = X"0001" report "JGZ with false condition failed" severity error;
    
    -- JGZ is true condition
    I_isLessThan <= '0';
    wait for 10 ns;
    assert O_NewPC = X"0005" report "JGZ with true condition failed" severity error;
    
    -- JRO/JMP backwards 
    I_PC <= X"0003";
    I_imm <= X"FFFE";
    I_jmpCondition <= "000";
    wait for 10 ns;
    assert O_NewPC = X"0001" report "Backwards JRO with immediate failed" severity error;
    
    -- JRO with register (fwd)
    I_regB_data <= X"0002";
    I_containsIMM <= '0';
    wait for 10 ns;
    assert O_NewPC = X"0005" report "Forward JRO with register failed" severity error;
    
    report "All tests completed";
    wait;
  end process;
END;
