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
    I_we3 : IN  std_logic;
    I_ra1 : IN  std_logic_vector(1 downto 0);
    I_ra2 : IN  std_logic_vector(1 downto 0);
    I_wa3 : IN  std_logic_vector(1 downto 0);
    I_wd3 : IN  std_logic_vector(WIDTH-1 downto 0);
    O_rd1 : OUT  std_logic_vector(WIDTH-1 downto 0);
    O_rd2 : OUT  std_logic_vector(WIDTH-1 downto 0)
  );
  END COMPONENT;

  --Inputs
  signal I_clk : std_logic := '0';
  signal I_we3 : std_logic := '0';
  signal I_ra1 : std_logic_vector(1 downto 0) := (others => '0');
  signal I_ra2 : std_logic_vector(1 downto 0) := (others => '0');
  signal I_wa3 : std_logic_vector(1 downto 0) := (others => '0');
  signal I_wd3 : std_logic_vector(REG_SIZE-1 downto 0) := (others => '0');

 	--Outputs
  signal O_rd1 : std_logic_vector(REG_SIZE-1 downto 0);
  signal O_rd2 : std_logic_vector(REG_SIZE-1 downto 0);

  -- Clock period definitions
  constant I_clk_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: register_file 
    GENERIC MAP (WIDTH => REG_SIZE)
    PORT MAP (
          I_clk => I_clk,
          I_we3 => I_we3,
          I_ra1 => I_ra1,
          I_ra2 => I_ra2,
          I_wa3 => I_wa3,
          I_wd3 => I_wd3,
          O_rd1 => O_rd1,
          O_rd2 => O_rd2
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
    I_we3 <= '1';
    I_wd3 <= X"0001";
    I_wa3 <= "00";
    wait for I_clk_period;

    -- Verify that reading the NIL register always returns 0
    I_ra1 <= "00";
    wait for I_clk_period;
    assert O_rd1 = X"0000" report "Error, NIL register != 0" severity ERROR;
--    assert O_rd1 /= X"0000" report "Reading NIL register produced 0 even after it was written" severity NOTE;

    -- Write the ACC register and verify it was written correctly.
    I_we3 <= '1';
    I_wd3 <= X"0acc";
    I_wa3 <= "01";
    wait for I_clk_period;
    I_ra1 <= "01";
    wait for I_clk_period;
    assert O_rd1 = X"0acc" report "Error, ACC register not written correctly" severity ERROR;
--    assert O_rd1 /= X"0acc" report "ACC written and read correctly" severity NOTE;

    -- Write the BAK register and read both ACC and back at the same time.
    I_we3 <= '1';
    I_wd3 <= X"bacc";
    I_wa3 <= "10";
    wait for I_clk_period;
    I_ra1 <= "10";
    I_ra2 <= "01";
    wait for I_clk_period;
    assert O_rd1 = X"bacc" report "Error, BAK register not written correctly" severity ERROR;
    assert O_rd2 = X"0acc" report "Error, ACC register not read correctly. Should have the last value." severity ERROR;
--    assert O_rd1 /= X"bacc" report "BAK written and read correctly" severity NOTE;
--    assert O_rd2 /= X"0acc" report "ACC read correctly for the second time." severity NOTE;

    -- Write the TMP register and verify it was written correctly.
    I_we3 <= '1';
    I_wd3 <= X"1234";
    I_wa3 <= "11";
    wait for I_clk_period;
    I_ra1 <= "11";
    wait for I_clk_period;
    assert O_rd1 = X"1234" report "Error, TMP register not written correctly" severity ERROR;
--    assert O_rd1 /= X"1234" report "TMP written and read correctly" severity NOTE;

    wait;
  end process;
END;
