LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY register_file_tb IS
END register_file_tb;
 
ARCHITECTURE behavior OF register_file_tb IS 
  constant REG_SIZE : integer := 16;
  
  -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT register_file
  GENERIC (WIDTH : integer := REG_SIZE);
  PORT(
    I_clk : IN  std_logic;
    I_swp : IN  std_logic;
    I_enableWrite : IN  std_logic;
    I_srcAID : IN  std_logic_vector(1 downto 0);
    I_srcBID : IN  std_logic_vector(1 downto 0);
    I_dstID : IN  std_logic_vector(1 downto 0);
    I_dstData : IN  std_logic_vector(WIDTH-1 downto 0);
    O_srcAData : OUT  std_logic_vector(WIDTH-1 downto 0);
    O_srcBData : OUT  std_logic_vector(WIDTH-1 downto 0)
  );
  END COMPONENT;

  --Inputs
  signal I_clk : std_logic := '0';
  signal I_swp : std_logic := '0';
  signal I_enableWrite : std_logic := '0';
  signal I_srcAID : std_logic_vector(1 downto 0) := (others => '0');
  signal I_srcBID : std_logic_vector(1 downto 0) := (others => '0');
  signal I_dstID : std_logic_vector(1 downto 0) := (others => '0');
  signal I_dstData : std_logic_vector(REG_SIZE-1 downto 0) := (others => '0');

 	--Outputs
  signal O_srcAData : std_logic_vector(REG_SIZE-1 downto 0);
  signal O_srcBData : std_logic_vector(REG_SIZE-1 downto 0);

  -- Clock period definitions
  constant I_clk_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: register_file 
    GENERIC MAP (WIDTH => REG_SIZE)
    PORT MAP (
          I_clk => I_clk,
          I_swp => I_swp,
          I_enableWrite => I_enableWrite,
          I_srcAID => I_srcAID,
          I_srcBID => I_srcBID,
          I_dstID => I_dstID,
          I_dstData => I_dstData,
          O_srcAData => O_srcAData,
          O_srcBData => O_srcBData
        );

  -- Clock process definitions 
  I_clk_process :process
  begin
    I_clk <= '0';
    wait for I_clk_period/2;
		I_clk <= '1';
		wait for I_clk_period/2;
  end process;

  -- Stimulus process
  stim_proc: process
  begin		
    -- Write the NIL register
    I_enableWrite <= '1';
    I_dstData <= X"0001";
    I_dstID <= "00";
    wait for I_clk_period;

    -- Verify that reading the NIL register always returns 0
    I_srcAID <= "00";
    wait for I_clk_period;
    assert O_srcAData = X"0000" report "Error, NIL register != 0" severity ERROR;

    -- Write the ACC register and verify it was written correctly.
    I_enableWrite <= '1';
    I_dstData <= X"0acc";
    I_dstID <= "01";
    wait for I_clk_period;
    I_srcAID <= "01";
    wait for I_clk_period;
    assert O_srcAData = X"0acc" report "Error, ACC register not written correctly" severity ERROR;

    -- Write the BAK register and read both ACC and back at the same time.
    I_enableWrite <= '1';
    I_dstData <= X"bacc";
    I_dstID <= "10";
    wait for I_clk_period;
    I_srcAID <= "10";
    I_srcBID <= "01";
    wait for I_clk_period;
    assert O_srcAData = X"bacc" report "Error, BAK register not written correctly" severity ERROR;
    assert O_srcBData = X"0acc" report "Error, ACC register not read correctly. Should have the last value." severity ERROR;

    -- Write the TMP register and verify it was written correctly.
    I_enableWrite <= '1';
    I_dstData <= X"1234";
    I_dstID <= "11";
    wait for I_clk_period;
    I_srcAID <= "11";
    wait for I_clk_period;
    assert O_srcAData = X"1234" report "Error, TMP register not written correctly" severity ERROR;
    
    -- SWP
    I_swp <= '1';
    wait for I_clk_period;
    
    -- Read ACC (should have the last value of BAK)
    I_swp <= '0';
    I_srcAID <= "01";
    I_srcBID <= "10";
    wait for I_clk_period;
    assert O_srcAData = X"bacc" report "Error, SWP didn't work correctly" severity ERROR;

    -- SWP regs in every clock cycle, till the end of times!
    I_swp <= '1';
    wait;
  end process;
END;
